//
//  SaveAsView.swift
//  Gotcha
//
//  MVVM - View: Save receipt with OCR + AI verification
//

import SwiftUI
import CoreData

struct SaveAsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    let selectedImage: UIImage?
    let fileName: String
    let searchText: String
    
    @StateObject private var viewModel: SaveAsViewModel
    
    init(selectedImage: UIImage?, fileName: String, searchText: String) {
        self.selectedImage = selectedImage
        self.fileName = fileName
        self.searchText = searchText
        _viewModel = StateObject(wrappedValue: SaveAsViewModel(
            viewContext: PersistenceController.shared.container.viewContext,
            onDismiss: {}
        ))
    }
    
    var body: some View {
        SaveAsContentView(viewModel: viewModel, selectedImage: selectedImage)
            .environment(\.managedObjectContext, viewContext)
            .onAppear {
                viewModel.configure(
                    selectedImage: selectedImage,
                    fileName: fileName,
                    searchText: searchText
                )
                viewModel.onDismiss = { dismiss() }
                if viewModel.needsAnalysis() {
                    viewModel.performFullAnalysis()
                }
            }
    }
}

private struct SaveAsContentView: View {
    @ObservedObject var viewModel: SaveAsViewModel
    let selectedImage: UIImage?
    
    var body: some View {
        ZStack {
            AppTheme.mainBackground.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .onTapGesture { viewModel.fullScreenImage = true }
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text("FILE NAME")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(AppTheme.deepText)
                        TextField("Enter File Name", text: $viewModel.fileName)
                            .padding()
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
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("VERIFIED DETAILS")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.deepText)
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                        }
                        VStack(spacing: 1) {
                            CustomTextField(label: "Store", text: $viewModel.storeName)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Date", text: $viewModel.date)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Total", text: $viewModel.totalAmount, keyboard: .decimalPad)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Address", text: $viewModel.address)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Payment", text: $viewModel.paymentMethod)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Customer", text: $viewModel.customerName)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Phone", text: $viewModel.phoneNumber, keyboard: .phonePad)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Receipt ID", text: $viewModel.receiptId)
                            Divider().background(Color.black.opacity(0.1))
                            CustomTextField(label: "Tracking", text: $viewModel.tracking)
                        }
                        .background(.ultraThinMaterial)
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal)
                    Button(action: { viewModel.validateAndSave() }) {
                        Text(viewModel.isLoading ? viewModel.statusMessage : "Save Receipt")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .background(viewModel.isLoading ? Color.gray.opacity(0.3) : Color.white.opacity(0.5))
                            .foregroundColor(AppTheme.deepText)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    Spacer(minLength: 50)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Verify Details")
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture { hideKeyboard() }
        .fullScreenCover(isPresented: $viewModel.fullScreenImage) {
            if let image = selectedImage {
                ZoomableFullScreenImage(image: image, fullScreenImage: $viewModel.fullScreenImage)
            }
        }
        .alert("File name required", isPresented: $viewModel.showFileAlert) {
            Button("OK", role: .cancel) { }
        }
        .alert("Saved Successfully", isPresented: $viewModel.showSavedAlert) {
            Button("OK") { viewModel.onSavedAlertDismiss() }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

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
    }
}
