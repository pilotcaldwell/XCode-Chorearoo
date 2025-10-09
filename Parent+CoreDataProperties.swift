//
//  Parent+CoreDataProperties.swift
//  chorearoo
//
//  Created by Chase Caldwell on 10/8/25.
//
//

public import Foundation
public import CoreData


public typealias ParentCoreDataPropertiesSet = NSSet

extension Parent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Parent> {
        return NSFetchRequest<Parent>(entityName: "Parent")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var lastName: String?
    @NSManaged public var profileImageUrl: String?
    @NSManaged public var role: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var children: NSSet?

}

// MARK: Generated accessors for children
extension Parent {

    @objc(addChildrenObject:)
    @NSManaged public func addToChildren(_ value: Child)

    @objc(removeChildrenObject:)
    @NSManaged public func removeFromChildren(_ value: Child)

    @objc(addChildren:)
    @NSManaged public func addToChildren(_ values: NSSet)

    @objc(removeChildren:)
    @NSManaged public func removeFromChildren(_ values: NSSet)

}

extension Parent : Identifiable {

}
