//
//  ReceiptRepository.swift
//  Gotcha
//
//  MVVM - Model: Core Data receipt operations
//

import Foundation
import CoreData
import UIKit

final class ReceiptRepository {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func save(
        fileName: String,
        image: UIImage?,
        storeName: String,
        date: String,
        totalAmount: String,
        address: String,
        paymentMethod: String,
        customerName: String,
        phoneNumber: String,
        receiptId: String,
        tracking: String
    ) throws {
        let newItem = ReceiptItem(context: viewContext)
        newItem.id = UUID()
        newItem.name = fileName
        
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.7) {
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
        
        try viewContext.save()
    }
    
    func delete(_ item: ReceiptItem) throws {
        viewContext.delete(item)
        try viewContext.save()
    }
}
