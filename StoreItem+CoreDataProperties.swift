//
//  StoreItem+CoreDataProperties.swift
//  chorearoo
//
//  Created by Chase Caldwell on 10/8/25.
//
//

public import Foundation
public import CoreData


public typealias StoreItemCoreDataPropertiesSet = NSSet

extension StoreItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreItem> {
        return NSFetchRequest<StoreItem>(entityName: "StoreItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var itemDescription: String?
    @NSManaged public var price: Double
    @NSManaged public var imageName: String?
    @NSManaged public var isAvailable: Bool
    @NSManaged public var createdAt: Date?

}

extension StoreItem : Identifiable {

}
