//
//  ReceiptFinderAppProperties.swift
//  Gotcha
//
//  Created by Rajahiresh Kalva on 8/13/25.
//

import Foundation
import CoreData
import UIKit

@objc(Item)
 class Item : NSManagedObject {
 
     @nonobjc class func fetchRequest() -> NSFetchRequest<Item> {
         return NSFetchRequest<Item>(entityName: "Item")
     }
     
     @NSManaged public var name: String?
     @NSManaged public var image: UIImage?
     @NSManaged public var id: UUID?
}

extension Item : Identifiable {
    
}
