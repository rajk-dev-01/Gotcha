//
//  ResultView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 7/30/25.
//

import SwiftUI
import CoreData
import PhotosUI

struct ResultView: View {
    @Binding var fileName: String
    @State var searchText: String = ""
    @State private var debouncedText: String = ""
    
    // ⚡️ Focus State
    @FocusState private var isSearchFocused: Bool
    
    @Binding var selectedImage: UIImage?
    @State var selectedItem: ReceiptItem?
    
    @State private var showScanner = false
    @State private var showPhotoPicker = false
    @State private var addNew = false
    @State private var navigateToSaveAs = false
    @State private var navigateToDetails = false
    
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        ZStack {
            // THEME: Main Green Gradient
            AppTheme.mainBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: - Glass Search Bar
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AppTheme.deepText.opacity(0.6))
                        
                        TextField("Search receipts...", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(AppTheme.deepText)
                            .font(.system(.body, design: .rounded))
                            .focused($isSearchFocused)
                            .submitLabel(.search)
                            // ⚡️ DEBOUNCE
                            .task(id: searchText) {
                                if searchText.isEmpty {
                                    debouncedText = ""
                                } else {
                                    try? await Task.sleep(nanoseconds: 500_000_000)
                                    await MainActor.run { debouncedText = searchText }
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                debouncedText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(4)
                            }
                        }
                    }
                    .padding(12)
                    // GLASS EFFECT
                    .background(.ultraThinMaterial)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    
                    if isSearchFocused || !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            debouncedText = ""
                            isSearchFocused = false
                        }) {
                            Text("Cancel")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(AppTheme.deepText) // 🟢 UPDATED: Dark Text
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                
                // MARK: - Feed Style Scroll
                FilteredReceiptsList(filter: debouncedText) { item in
                    selectedItem = item
                    navigateToDetails = true
                }
                .scrollDismissesKeyboard(.immediately)
                
                // MARK: - Glass Add Button (RESTORED to VStack)
                if !isSearchFocused && searchText.isEmpty {
                    Button(action: { addNew = true }) {
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
                        // GLASS EFFECT
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
                    .confirmationDialog("Select an option", isPresented: $addNew, titleVisibility: .visible) {
                        Button("Open Camera") { showScanner = true }
                        Button("Add from Library") { showPhotoPicker = true }
                        Button("Cancel", role: .cancel) { }
                    }
                }
            }
        }
        
        // MARK: - Navigation
        .navigationDestination(isPresented: $navigateToDetails) {
            if let item = selectedItem {
                DetailsView(item: item)
            }
        }
        .navigationDestination(isPresented: $navigateToSaveAs) {
            SaveAsView(
                selectedImage: $selectedImage,
                fileName: "",
                searchText: searchText
            )
            .environment(\.managedObjectContext, viewContext)
        }
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScannerView { image in
                self.selectedImage = image
                self.navigateToSaveAs = true
            }
            .ignoresSafeArea(.all)
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectedImage: $selectedImage) { image in
                guard let image = image else { return }
                self.selectedImage = image
                self.navigateToSaveAs = true
            }
        }
    }
}

// Subview: "One-by-One" Snap Scrolling + Clean UI + Swipe to Delete
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
                        .foregroundColor(AppTheme.deepText) // 🟢 UPDATED: Dark Text
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 50)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(fetchRequest) { item in
                            // SWIPEABLE ROW WRAPPER
                            SwipeItem(width: geo.size.width, onDelete: {
                                deleteItem(item)
                            }) {
                                // YOUR CARD CONTENT
                                Button { onSelect(item) } label: {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 15) {
                                            // 1. Thumbnail
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
                                            
                                            // 2. Text Content
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
                                    .frame(width: geo.size.width)
                                    .contentShape(Rectangle())
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

// MARK: - Swipe Logic (Unchanged)
struct SwipeItem<Content: View>: View {
    let width: CGFloat
    let onDelete: () -> Void
    let content: () -> Content
    
    @State private var offset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 0) {
            content()
                .frame(width: width)
            
            // Delete Button Area
            ZStack {
                Color.red
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .font(.title3)
            }
            .frame(width: 100)
            .onTapGesture {
                onDelete()
            }
        }
        .frame(width: width, alignment: .leading)
        .offset(x: offset)
        .highPriorityGesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onChanged { value in
                    if value.translation.width < 0 {
                        self.offset = value.translation.width
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if value.translation.width < -90 {
                            if value.translation.width < -250 {
                                onDelete()
                                self.offset = 0
                            } else {
                                self.offset = -100
                            }
                        } else {
                            self.offset = 0
                        }
                    }
                }
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                if offset < 0 {
                    withAnimation { offset = 0 }
                }
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
