//
//  DetailsViewModel.swift
//  Gotcha
//
//  MVVM - ViewModel for receipt detail display
//

import SwiftUI
import CoreData

final class DetailsViewModel: ObservableObject {
    // MARK: - Published State
    @Published var showFullScreenImage = false
    
    // MARK: - Model
    let item: ReceiptItem
    
    init(item: ReceiptItem) {
        self.item = item
    }
    
    // MARK: - Computed
    var receiptImage: UIImage? {
        guard let imageData = item.image else { return nil }
        return UIImage(data: imageData)
    }
    
    // MARK: - Actions
    func toggleFullScreenImage() {
        showFullScreenImage.toggle()
    }
}
