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
                
                // 🔹 Receipt Image (Convert Data -> UIImage)
                if let imageData = item.image, let image = UIImage(data: imageData) {
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
                } else {
                    Text("No Image Available")
                        .foregroundColor(.gray)
                        .padding()
                }
                
                Divider()
                
                // 🔹 Details Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Receipt Details")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    
                    Group {
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
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.bottom, 30)
        }
        .navigationTitle("Receipt Info")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func rowView(label: String, value: String?) -> some View {
        HStack(alignment: .top) {
            Text("\(label):")
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(width: 110, alignment: .leading)
            
            Text(value?.isEmpty == false ? value! : "Not Available")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 2)
    }
}



