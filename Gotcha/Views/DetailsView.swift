//
//  DetailsView.swift
//  Gotcha
//
//  MVVM - View: Receipt detail display
//

import SwiftUI
import CoreData

struct DetailsView: View {
    @StateObject private var viewModel: DetailsViewModel
    
    init(item: ReceiptItem) {
        _viewModel = StateObject(wrappedValue: DetailsViewModel(item: item))
    }
    
    var body: some View {
        ZStack {
            AppTheme.mainBackground.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .center, spacing: 15) {
                    Spacer()
                    if let fileName = viewModel.item.name {
                        Text(fileName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(AppTheme.deepText)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .background(Color.white.opacity(0.4))
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    if let image = viewModel.receiptImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding()
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                            .onTapGesture { viewModel.toggleFullScreenImage() }
                            .fullScreenCover(isPresented: $viewModel.showFullScreenImage) {
                                ZoomableFullScreenImage(image: image, fullScreenImage: $viewModel.showFullScreenImage)
                            }
                    } else {
                        Text("No Image Available")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(AppTheme.deepText)
                            .padding()
                    }
                    Divider().background(Color.white.opacity(0.5))
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Receipt Details")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .foregroundColor(AppTheme.deepText)
                        Group {
                            rowView(label: "Store", value: viewModel.item.storeName)
                            rowView(label: "Date", value: viewModel.item.date)
                            rowView(label: "Total", value: viewModel.item.totalAmount)
                            rowView(label: "Address", value: viewModel.item.address)
                            rowView(label: "Payment", value: viewModel.item.paymentMethod)
                            rowView(label: "Customer", value: viewModel.item.customerName)
                            rowView(label: "Phone", value: viewModel.item.phoneNumber)
                            rowView(label: "Receipt ID", value: viewModel.item.receiptId)
                            rowView(label: "Tracking", value: viewModel.item.tracking)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .background(Color.white.opacity(0.3))
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
