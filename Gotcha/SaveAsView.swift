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
    
    // Extracted Fields (ALL FIELDS PRESERVED)
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
        ZStack {
            // THEME: Green Gradient
            AppTheme.mainBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - Image Section
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .onTapGesture { fullScreenImage.toggle() }
                    }
                    
                    // MARK: - File Name (Glass Style)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("FILE NAME")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.deepText) // Dark Text
                        
                        TextField("Enter File Name", text: $fileName)
                            .padding()
                            // GLASS EFFECT
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .foregroundColor(AppTheme.deepText)
                            .font(.system(.body, design: .rounded))
                            .submitLabel(.done)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Details Section
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("VERIFIED DETAILS")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.deepText)
                            Spacer()
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        
                        // Fields Container (Glass Card)
                        VStack(spacing: 1) {
                            CustomTextField(label: "Store", text: $storeName)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Date", text: $date)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Total", text: $totalAmount, keyboard: .decimalPad)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Address", text: $address)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Payment", text: $paymentMethod)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Customer", text: $customerName)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Phone", text: $phoneNumber, keyboard: .phonePad)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Receipt ID", text: $receiptId)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Tracking", text: $tracking)
                        }
                        // GLASS EFFECT
                        .background(.ultraThinMaterial)
                        .background(Color.white.opacity(0.3)) // Milky tint
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Save Button (Glass Style)
                    Button(action: validateAndSave) {
                        Text(isLoading ? statusMessage : "Save Receipt")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            // GLASS BUTTON
                            .background(.ultraThinMaterial)
                            .background(isLoading ? Color.gray.opacity(0.3) : Color.white.opacity(0.5))
                            .foregroundColor(AppTheme.deepText)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .disabled(isLoading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Verify Details")
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture {
            hideKeyboard()
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
    
    // MARK: - Helper Methods (UNCHANGED)
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

// ✅ Glass Styled TextField Component
struct CustomTextField: View {
    let label: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .frame(width: 90, alignment: .leading)
                .foregroundColor(AppTheme.deepText.opacity(0.7))
            
            TextField("Required", text: $text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(AppTheme.deepText)
                .keyboardType(keyboard)
                .submitLabel(.done)
        }
        .padding()
        // No explicit background color here so it inherits the glass from the container
    }
}
