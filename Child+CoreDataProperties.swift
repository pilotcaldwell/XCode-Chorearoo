//
//  Child+CoreDataProperties.swift
//  chorearoo
//
//  Created by Chase Caldwell on 10/8/25.
//
//

public import Foundation
public import CoreData


public typealias ChildCoreDataPropertiesSet = NSSet

extension Child {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Child> {
        return NSFetchRequest<Child>(entityName: "Child")
    }

    @NSManaged public var age: Int16
    @NSManaged public var avatarColor: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var givingBalance: Double
    @NSManaged public var name: String?
    @NSManaged public var pin: String?
    @NSManaged public var savingsBalance: Double
    @NSManaged public var spendingBalance: Double
    @NSManaged public var id: UUID?
    @NSManaged public var choreCompletions: NSSet?
    @NSManaged public var parents: NSSet?

}

// MARK: Generated accessors for choreCompletions
extension Child {

    @objc(addChoreCompletionsObject:)
    @NSManaged public func addToChoreCompletions(_ value: ChoreCompletion)

    @objc(removeChoreCompletionsObject:)
    @NSManaged public func removeFromChoreCompletions(_ value: ChoreCompletion)

    @objc(addChoreCompletions:)
    @NSManaged public func addToChoreCompletions(_ values: NSSet)

    @objc(removeChoreCompletions:)
    @NSManaged public func removeFromChoreCompletions(_ values: NSSet)

}

// MARK: Generated accessors for parents
extension Child {

    @objc(addParentsObject:)
    @NSManaged public func addToParents(_ value: Parent)

    @objc(removeParentsObject:)
    @NSManaged public func removeFromParents(_ value: Parent)

    @objc(addParents:)
    @NSManaged public func addToParents(_ values: NSSet)

    @objc(removeParents:)
    @NSManaged public func removeFromParents(_ values: NSSet)

}

extension Child : Identifiable {

}
