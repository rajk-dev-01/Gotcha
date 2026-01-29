//
//  DetailsView.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/7/25.
//

import SwiftUI
import CoreData

struct DetailsView: View {
    var item: ReceiptItem
    
    @State private var fullScreenImage: Bool = false
    
    var body: some View {
        ZStack {
            // THEME: Green Gradient
            AppTheme.mainBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .center, spacing: 15) {
                    Spacer()
                    
                    // 🔹 File Name (Glass Pill)
                    if let fileName = item.name {
                        Text(fileName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(AppTheme.deepText)
                            .padding(10)
                            // GLASS EFFECT
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.4))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    
                    // 🔹 Receipt Image
                    if let imageData = item.image, let image = UIImage(data: imageData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            .onTapGesture {
                                fullScreenImage.toggle()
                            }
                            .fullScreenCover(isPresented: $fullScreenImage) {
                                ZoomableFullScreenImage(image: image, fullScreenImage: $fullScreenImage)
                            }
                    } else {
                        Text("No Image Available")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppTheme.deepText)
                            .padding()
                    }
                    
                    Divider().background(Color.white.opacity(0.5))
                    
                    // 🔹 Details Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Receipt Details")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .foregroundColor(AppTheme.deepText)
                        
                        Group {
                            // UNCHANGED LOGIC
                            rowView(label: "Store", value: item.storeName)
                            rowView(label: "Date", value: item.date)
                            rowView(label: "Total", value: item.totalAmount)
                            rowView(label: "Address", value: item.address)
                            rowView(label: "Payment", value: item.paymentMethod)
                            rowView(label: "Customer", value: item.customerName)
                            rowView(label: "Phone", value: item.phoneNumber)
                            rowView(label: "Receipt ID", value: item.receiptId)
                            rowView(label: "Tracking", value: item.tracking)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // GLASS CARD
                    .background(.ultraThinMaterial)
                    .background(Color.white.opacity(0.3)) // Milky tint
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Receipt Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func rowView(label: String, value: String?) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(AppTheme.deepText)
                .frame(width: 110, alignment: .leading)
            
            Text(value?.isEmpty == false ? value! : "Not Available")
                .font(.system(.body, design: .rounded))
                .foregroundColor(AppTheme.deepText.opacity(0.8))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}


