//
//  SaveAsViewModel.swift
//  Gotcha
//
//  MVVM - ViewModel for the save receipt flow (OCR + AI + Core Data)
//

import SwiftUI
import CoreData

@MainActor
final class SaveAsViewModel: ObservableObject {
    // MARK: - Dependencies
    private let openAIService = OpenAIService()
    private let receiptRepository: ReceiptRepository
    var onDismiss: () -> Void
    
    // MARK: - Input
    var selectedImage: UIImage?
    var initialFileName: String = ""
    var searchContext: String = ""
    
    // MARK: - Form Fields
    @Published var fileName: String = ""
    @Published var storeName: String = ""
    @Published var date: String = ""
    @Published var totalAmount: String = ""
    @Published var address: String = ""
    @Published var paymentMethod: String = ""
    @Published var customerName: String = ""
    @Published var phoneNumber: String = ""
    @Published var receiptId: String = ""
    @Published var tracking: String = ""
    
    // MARK: - UI State
    @Published var fullScreenImage = false
    @Published var showFileAlert = false
    @Published var showSavedAlert = false
    @Published var isLoading = false
    @Published var statusMessage = ""
    
    init(viewContext: NSManagedObjectContext, onDismiss: @escaping () -> Void = {}) {
        self.receiptRepository = ReceiptRepository(viewContext: viewContext)
        self.onDismiss = onDismiss
    }
    
    func configure(selectedImage: UIImage?, fileName: String, searchText: String) {
        self.selectedImage = selectedImage
        self.initialFileName = fileName
        self.searchContext = searchText
        self.fileName = fileName
    }
    
    // MARK: - Actions
    func performFullAnalysis() {
        guard let image = selectedImage else { return }
        isLoading = true
        statusMessage = "Scanning..."
        
        OCRHelper.extractText(from: image) { [weak self] text in
            Task { @MainActor in
                guard let self = self else { return }
                self.statusMessage = "AI Analyzing..."
                
                do {
                    let result = try await self.openAIService.extractReceiptInfo(from: text)
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
                } catch {
                    print("❌ Analysis failed: \(error)")
                }
                self.isLoading = false
            }
        }
    }
    
    func validateAndSave() {
        if fileName.trimmingCharacters(in: .whitespaces).isEmpty {
            showFileAlert = true
        } else {
            saveReceipt()
        }
    }
    
    private func saveReceipt() {
        guard let image = selectedImage else { return }
        
        do {
            try receiptRepository.save(
                fileName: fileName,
                image: image,
                storeName: storeName,
                date: date,
                totalAmount: totalAmount,
                address: address,
                paymentMethod: paymentMethod,
                customerName: customerName,
                phoneNumber: phoneNumber,
                receiptId: receiptId,
                tracking: tracking
            )
            showSavedAlert = true
        } catch {
            print("❌ Save failed: \(error)")
        }
    }
    
    func onSavedAlertDismiss() {
        onDismiss()
    }
    
    func needsAnalysis() -> Bool {
        storeName.isEmpty
    }
}
