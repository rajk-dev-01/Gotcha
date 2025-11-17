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
    @State var searchText: String
    @Binding var selectedImage: UIImage?
    @State var selectedItem: Item?
    
    @State private var showScanner = false
    @State private var showPhotoPicker = false
    @State private var addNew = false
    @State private var recognizedText = ""
    @State private var navigateToSaveAs = false
    @State private var navigateToDetails = false
    @State private var isProcessing = false
    
    @FetchRequest(
        entity: Item.entity(),
        sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]
    ) var items: FetchedResults<Item>
    
    @Environment(\.managedObjectContext) var viewContext
    
    var body: some View {
        ZStack {
            VStack {
                List {
                    Section("Previous Activity") {
                        ForEach(filteredItems) { item in
                            Button {
                                selectedItem = item
                                navigateToDetails = true
                            } label: {
                                Text(item.name ?? "Unnamed")
                            }
                        }
                        .onDelete(perform: deleteItem)
                    }
                }
                
                Button("Add New Receipt") {
                    addNew = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 300, height: 50)
                .background(Color.blue)
                .cornerRadius(15)
                .confirmationDialog("Select an option",
                                    isPresented: $addNew,
                                    titleVisibility: .visible) {
                    Button("Open Camera") {
                        showScanner = true
                    }
                    Button("Add from Library") {
                        showPhotoPicker = true
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            
            if isProcessing {
                Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
                ProgressView("Processing...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
            }
        }
        .searchable(text: $searchText, prompt: "Search")
        
        // Navigation to Details
        .navigationDestination(isPresented: $navigateToDetails) {
            if let item = selectedItem {
                DetailsView(
                    item: item,
                    recognizedText: recognizedText
                )
            }
        }
        
        // Navigation to SaveAs
        .navigationDestination(isPresented: $navigateToSaveAs) {
            SaveAsView(
                fileName: "",
                searchText: searchText,
                selectedImage: $selectedImage
            )
            .environment(\.managedObjectContext, viewContext)
        }
        
        // Scanner (Camera)
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScannerView { images, text in
                isProcessing = true
                selectedImage = images.first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    recognizedText = text
                    isProcessing = false
                    navigateToSaveAs = true
                }
            }
            .ignoresSafeArea(.all)
        }
        
        // Photo Picker (Gallery)
        .sheet(isPresented: $showPhotoPicker) {
            PhotoPicker(selectedImage: $selectedImage) { image in
                guard let image = image else { return }
                isProcessing = true
                OCRHelper.extractText(from: image) { text in
                    recognizedText = text
                    isProcessing = false
                    navigateToSaveAs = true
                }
            }
        }
    }
    
    // MARK: - Delete
    private func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            viewContext.delete(item)
        }
        try? viewContext.save()
    }
    
    // MARK: - Filtered Items
    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return Array(items)
        } else {
            return items.filter { $0.name?.localizedCaseInsensitiveContains(searchText) ?? false }
        }
    }
}


