//
//  SaveAsView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/4/25.
//

import SwiftUI
import CoreData

struct SaveAsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var fileName: String
    @State var searchText: String
    @Binding var selectedImage: UIImage?
    
    @State var fullScreenImage = false
    
    @State private var showFileAlert = false
    @State private var okAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            // ✅ File name input
            HStack{
                Text("FileName:")
                    .font(.headline)
                TextField("Enter FileName", text: $fileName)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
            }.padding()
            
            // ✅ Preview selected image
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .onTapGesture {
                        fullScreenImage.toggle()
                    }
                    .fullScreenCover(isPresented: $fullScreenImage) {
                        ZoomableFullScreenImage(image: image, fullScreenImage: $fullScreenImage)
                    }
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // ✅ Save button
            Button("Save") {
                if fileName.trimmingCharacters(in: .whitespaces).isEmpty {
                    showFileAlert = true
                } else {
                    saveReceipt()
                }
            }
            .font(.headline)
            .frame(width:300, height: 50)
            .background(.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
            .padding(30)

            
            Spacer()
        }
        .alert("File name required", isPresented: $showFileAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Added Receipt Successfully", isPresented: $okAlert) {
            Button("OK") {
                dismiss() // ✅ Go back to ResultView after saving
            }
        }
    }
    
    // MARK: - Save to Core Data
    private func saveReceipt() {
        let newItem = Item(context: viewContext)
        newItem.id = UUID()
        newItem.name = fileName
        if let uiImage = selectedImage {
            newItem.image = uiImage
        }
        
        do {
            try viewContext.save()
            okAlert = true
        } catch {
            print("❌ Failed to save receipt: \(error)")
        }
    }
}
