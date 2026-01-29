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
    
    // ⚡️ Focus State: Controls the keyboard
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
            VStack(spacing: 0) {
                
                // MARK: - Search Bar & Cancel Button
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search receipts...", text: $searchText)
                            .textFieldStyle(.plain)
                            .focused($isSearchFocused)
                            .submitLabel(.search)
                            // ⚡️ DEBOUNCE: Prevents lag while typing
                            .task(id: searchText) {
                                if searchText.isEmpty {
                                    debouncedText = "" // Instant clear if empty
                                } else {
                                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s wait
                                    await MainActor.run { debouncedText = searchText }
                                }
                            }
                        
                        // 'X' Button inside the bar
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                debouncedText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(4) // Increase touch target
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // ⚡️ FIXED CANCEL BUTTON
                    if isSearchFocused || !searchText.isEmpty {
                        Button(action: {
                            // 1. Force immediate UI update (Bypass debounce)
                            searchText = ""
                            debouncedText = ""
                            
                            // 2. Kill keyboard immediately
                            isSearchFocused = false
                        }) {
                            Text("Cancel")
                                .font(.body)
                                .foregroundColor(.blue)
                                .padding(.vertical, 10) // Taller touch area
                                .contentShape(Rectangle()) // Makes the empty space tappable
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding()
                .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
                
                // MARK: - List Results
                FilteredReceiptsList(filter: debouncedText) { item in
                    selectedItem = item
                    navigateToDetails = true
                }
                .scrollDismissesKeyboard(.immediately) // iOS 16+ Keyboard fix
                
                // MARK: - Add Button (Hidden when searching)
                if !isSearchFocused && searchText.isEmpty {
                    Button("Add New Receipt") { addNew = true }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 300, height: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                        .padding(.bottom, 10)
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
        
        // MARK: - Scanner & Picker
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

// Subview remains the same (FilteredReceiptsList)
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
        List {
            if fetchRequest.isEmpty {
                Text("No receipts found")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 50)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(fetchRequest) { item in
                    Button { onSelect(item) } label: {
                        HStack(spacing: 15) {
                            if let imageData = item.image, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                                    .clipped()
                            } else {
                                Image(systemName: "doc.text.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.name ?? "Unnamed Receipt")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                if let date = item.date, !date.isEmpty {
                                    Text(date).font(.caption).foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { fetchRequest[$0] }.forEach(viewContext.delete)
                    try? viewContext.save()
                }
            }
        }
        .listStyle(.plain)
    }
}
