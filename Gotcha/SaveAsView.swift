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
    
    @Binding var selectedImage: UIImage?
    @State var fileName: String
    @State var searchText: String
    
    // Extracted Fields
    @State private var storeName: String = ""
    @State private var date: String = ""
    @State private var totalAmount: String = ""
    @State private var address: String = ""
    @State private var paymentMethod: String = ""
    @State private var customerName: String = ""
    @State private var phoneNumber: String = ""
    @State private var receiptId: String = ""
    @State private var tracking: String = ""
    
    @State private var fullScreenImage = false
    @State private var showFileAlert = false
    @State private var okAlert = false
    @State private var isLoading = false
    @State private var statusMessage = ""
    
    private let openAIService = OpenAIService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: - Image Section
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .onTapGesture { fullScreenImage.toggle() }
                }
                
                // MARK: - File Name
                VStack(alignment: .leading, spacing: 5) {
                    Text("FILE NAME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    TextField("Enter File Name", text: $fileName)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .submitLabel(.done) // ✅ Adds "Done" button to keyboard
                }
                .padding(.horizontal)
                
                // MARK: - Details Section
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("VERIFIED DETAILS")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                    
                    // Fields Container
                    VStack(spacing: 1) {
                        CustomTextField(label: "Store", text: $storeName)
                        Divider()
                        CustomTextField(label: "Date", text: $date)
                        Divider()
                        CustomTextField(label: "Total", text: $totalAmount, keyboard: .decimalPad)
                        Divider()
                        CustomTextField(label: "Address", text: $address)
                        Divider()
                        CustomTextField(label: "Payment", text: $paymentMethod)
                        Divider()
                        CustomTextField(label: "Customer", text: $customerName)
                        Divider()
                        CustomTextField(label: "Phone", text: $phoneNumber, keyboard: .phonePad)
                        Divider()
                        CustomTextField(label: "Receipt ID", text: $receiptId)
                        Divider()
                        CustomTextField(label: "Tracking", text: $tracking)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // MARK: - Save Button
                Button(action: validateAndSave) {
                    Text(isLoading ? statusMessage : "Save Receipt")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(isLoading)
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer(minLength: 50)
            }
            .padding(.vertical)
        }
        .navigationTitle("Verify Details")
        .scrollDismissesKeyboard(.interactively) // ✅ Dismiss keyboard on scroll
        .onTapGesture {
            hideKeyboard() // ✅ Dismiss keyboard on background tap
        }
        .fullScreenCover(isPresented: $fullScreenImage) {
            if let image = selectedImage {
                ZoomableFullScreenImage(image: image, fullScreenImage: $fullScreenImage)
            }
        }
        .onAppear {
            if storeName.isEmpty {
                performFullAnalysis()
            }
        }
        .alert("File name required", isPresented: $showFileAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Saved Successfully", isPresented: $okAlert) {
            Button("OK") { dismiss() }
        }
    }
    
    // MARK: - Helper Methods
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func performFullAnalysis() {
        guard let image = selectedImage else { return }
        isLoading = true
        statusMessage = "Scanning..."
        
        OCRHelper.extractText(from: image) { text in
            Task {
                await MainActor.run { self.statusMessage = "AI Analyzing..." }
                do {
                    let result = try await openAIService.extractReceiptInfo(from: text)
                    await MainActor.run {
                        self.storeName = result["storeName"] as? String ?? ""
                        self.date = result["date"] as? String ?? ""
                        self.totalAmount = result["totalAmount"] as? String ?? ""
                        self.address = result["address"] as? String ?? ""
                        self.paymentMethod = result["paymentMethod"] as? String ?? ""
                        self.customerName = result["name"] as? String ?? ""
                        self.phoneNumber = result["phoneNumber"] as? String ?? ""
                        self.receiptId = result["receiptId"] as? String ?? ""
                        self.tracking = result["tracking"] as? String ?? ""
                        
                        if self.fileName.isEmpty {
                            self.fileName = "\(self.storeName) Receipt"
                        }
                        self.isLoading = false
                    }
                } catch {
                    print("❌ Analysis failed: \(error)")
                    await MainActor.run { self.isLoading = false }
                }
            }
        }
    }
    
    private func validateAndSave() {
        if fileName.trimmingCharacters(in: .whitespaces).isEmpty {
            showFileAlert = true
        } else {
            saveToCoreData()
        }
    }
    
    private func saveToCoreData() {
        let newItem = ReceiptItem(context: viewContext)
        newItem.id = UUID()
        newItem.name = fileName
        
        if let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.7) {
            newItem.image = imageData
        }
        
        newItem.storeName = storeName
        newItem.date = date
        newItem.totalAmount = totalAmount
        newItem.address = address
        newItem.paymentMethod = paymentMethod
        newItem.customerName = customerName
        newItem.phoneNumber = phoneNumber
        newItem.receiptId = receiptId
        newItem.tracking = tracking
        
        viewContext.performAndWait {
            try? viewContext.save()
            okAlert = true
        }
    }
}

// ✅ Optimized TextField Component
struct CustomTextField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 90, alignment: .leading)
                .foregroundColor(.primary)
            
            TextField("Required", text: $text)
                .font(.body)
                .foregroundColor(.blue)
                .keyboardType(keyboard)
                .submitLabel(.done) // Add Done button to keyboard
        }
        .padding()
        .background(Color(.systemGray6)) // Keeps it fast to render
    }
}
