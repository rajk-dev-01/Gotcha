//
//  ResultView.swift
//  Gotcha
//
//  MVVM - View: Receipt list, search, and add flow
//

import SwiftUI
import CoreData
import PhotosUI

struct ResultView: View {
    @StateObject private var viewModel = ResultViewModel()
    @FocusState private var isSearchFocused: Bool
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ZStack {
            AppTheme.mainBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                FilteredReceiptsList(filter: viewModel.debouncedText) { item in
                    viewModel.selectReceipt(item)
                }
                .scrollDismissesKeyboard(.immediately)
                
                if !isSearchFocused && viewModel.searchText.isEmpty {
                    addButton
                }
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToDetails) {
            if let item = viewModel.selectedItem {
                DetailsView(item: item)
            }
        }
        .navigationDestination(isPresented: $viewModel.navigateToSaveAs) {
            SaveAsView(
                selectedImage: viewModel.selectedImage,
                fileName: "",
                searchText: viewModel.searchText
            )
            .environment(\.managedObjectContext, viewContext)
        }
        .fullScreenCover(isPresented: $viewModel.showScanner) {
            DocumentScannerView { image in
                viewModel.onImageSelectedForSave(image)
            }
            .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $viewModel.showPhotoPicker) {
            PhotoPicker(selectedImage: Binding(
                get: { viewModel.selectedImage },
                set: { viewModel.selectedImage = $0 }
            )) { image in
                guard let image = image else { return }
                viewModel.onImageSelectedForSave(image)
            }
        }
        .confirmationDialog("Select an option", isPresented: $viewModel.addNew, titleVisibility: .visible) {
            Button("Open Camera") { viewModel.onAddOptionCamera() }
            Button("Add from Library") { viewModel.onAddOptionLibrary() }
            Button("Cancel", role: .cancel) { viewModel.cancelAdd() }
        }
    }
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.deepText.opacity(0.6))
                TextField("Search receipts...", text: $viewModel.searchText)
                    .textFieldStyle(.plain)
                    .foregroundColor(AppTheme.deepText)
                    .font(.system(.body, design: .rounded))
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                if !viewModel.searchText.isEmpty {
                    Button(action: { viewModel.clearSearch() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                            .padding(4)
                    }
                }
            }
            .padding(12)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            if isSearchFocused || !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.dismissSearchFocus()
                    isSearchFocused = false
                }) {
                    Text("Cancel")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.deepText)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
    }
    
    private var addButton: some View {
        Button(action: { viewModel.onAddNew() }) {
            HStack(spacing: 10) {
                Image(systemName: "plus")
                    .font(.system(.headline, design: .rounded))
                Text("Add New Receipt")
                    .font(.system(.headline, design: .rounded))
            }
            .foregroundColor(AppTheme.deepText)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial)
            .background(Color.white.opacity(0.3))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .padding(.horizontal, 40)
        .padding(.bottom, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

struct FilteredReceiptsList: View {
    @FetchRequest var fetchRequest: FetchedResults<ReceiptItem>
    @Environment(\.managedObjectContext) var viewContext
    var onSelect: (ReceiptItem) -> Void
    
    init(filter: String, onSelect: @escaping (ReceiptItem) -> Void) {
        self.onSelect = onSelect
        let predicate: NSPredicate? = filter.isEmpty ? nil : NSPredicate(format: "name CONTAINS[cd] %@", filter)
        _fetchRequest = FetchRequest<ReceiptItem>(
            sortDescriptors: [NSSortDescriptor(key: "date", ascending: false)],
            predicate: predicate,
            animation: .default
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                if fetchRequest.isEmpty {
                    Text("No receipts found")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(AppTheme.deepText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(fetchRequest) { item in
                            SwipeItem(width: geo.size.width, onDelete: { deleteItem(item) }) {
                                Button { onSelect(item) } label: {
                                    ReceiptRowView(item: item, width: geo.size.width)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.horizontal, 20)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    private func deleteItem(_ item: ReceiptItem) {
        withAnimation {
            viewContext.delete(item)
            try? viewContext.save()
        }
    }
}

struct ReceiptRowView: View {
    let item: ReceiptItem
    let width: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 15) {
                if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .cornerRadius(15)
                        .clipped()
                } else {
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(AppTheme.brandGreenDark)
                        .frame(width: 60, height: 60)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name ?? "Unnamed Receipt")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.deepText)
                        .lineLimit(1)
                    if let date = item.date, !date.isEmpty {
                        Text(date)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(AppTheme.deepText.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
        }
        .frame(width: width)
        .contentShape(Rectangle())
    }
}

struct SwipeItem<Content: View>: View {
    let width: CGFloat
    let onDelete: () -> Void
    let content: () -> Content
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 0) {
            content()
                .frame(width: width)
            ZStack {
                Color.red
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            .frame(width: 100)
            .onTapGesture { onDelete() }
        }
        .frame(width: width, alignment: .leading)
        .offset(x: offset)
        .highPriorityGesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onChanged { value in
                    if value.translation.width < 0 { offset = value.translation.width }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if value.translation.width < -90 {
                            if value.translation.width < -250 {
                                onDelete()
                                offset = 0
                            } else { offset = -100 }
                        } else { offset = 0 }
                    }
                }
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                if offset < 0 { withAnimation { offset = 0 } }
            }
        )
        .clipped()
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
