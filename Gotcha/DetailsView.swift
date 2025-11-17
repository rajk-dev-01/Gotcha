//
//  DetailsView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/7/25.
//

import SwiftUI

struct DetailsView: View {
    var item: Item
    var recognizedText: String // ✅ raw OCR text passed here
    
    @State private var fullScreenImage: Bool = false
    @State private var extractedInfo: [String: Any]?
    @State private var isLoading = false
    
    private let service = OpenAIService() // assumes you implemented earlier
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                
                // 🔹 File Name
                if let fileName = item.name {
                    Text(fileName)
                        .font(.headline)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(5)
                        .padding(.horizontal)
                }
                
                // 🔹 Receipt Image
                if let image = item.image as? UIImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding()
                        .onTapGesture {
                            fullScreenImage.toggle()
                        }
                        .fullScreenCover(isPresented: $fullScreenImage) {
                            ZoomableFullScreenImage(image: image, fullScreenImage: $fullScreenImage)
                        }
                }
                
                Divider()
                
                // 🔹 Extracted Info Section
                if isLoading {
                    ProgressView("Analyzing receipt…")
                        .padding()
                } else if let info = extractedInfo {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Store: \(info["storeName"] as? String ?? "Unknown")")
                        Text("Date: \(info["date"] as? String ?? "Unknown")")
                        Text("Total: \(info["totalAmount"] as? String ?? "Unknown")")
                        Text("Address: \(info["address"] as? String ?? "Unknown")")
                        Text("Payment: \(info["paymentMethod"] as? String ?? "Unknown")")
                        Text("Name: \(info["name"] as? String ?? "Unknown")")
                        Text("PhoneNumber: \(info["phoneNumber"] as? String ?? "Unknown")")
                        Text("ReceiptID: \(info["receiptId"] as? String ?? "Unknown")")
                        Text("TrackingNumber: \(info["tracking"] as? String ?? "Unknown")")

                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // 🔹 Parse Button
                Button("Extract Receipt Details") {
                    analyzeReceipt()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - ChatGPT Integration
    private func analyzeReceipt() {
        guard !recognizedText.isEmpty else { return }
        
        isLoading = true
        service.extractReceiptInfo(from: recognizedText) { result in
            DispatchQueue.main.async {
                self.extractedInfo = result
                self.isLoading = false
            }
        }
    }
}



