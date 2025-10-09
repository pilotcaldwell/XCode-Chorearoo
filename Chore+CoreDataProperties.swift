//
//  Chore+CoreDataProperties.swift
//  chorearoo
//
//  Created by Chase Caldwell on 10/8/25.
//
//

public import Foundation
public import CoreData


public typealias ChoreCoreDataPropertiesSet = NSSet

extension Chore {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chore> {
        return NSFetchRequest<Chore>(entityName: "Chore")
    }

    @NSManaged public var amount: Double
    @NSManaged public var choreDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var choreCompletions: NSSet?

}

// MARK: Generated accessors for choreCompletions
extension Chore {

    @objc(addChoreCompletionsObject:)
    @NSManaged public func addToChoreCompletions(_ value: ChoreCompletion)

    @objc(removeChoreCompletionsObject:)
    @NSManaged public func removeFromChoreCompletions(_ value: ChoreCompletion)

    @objc(addChoreCompletions:)
    @NSManaged public func addToChoreCompletions(_ values: NSSet)

    @objc(removeChoreCompletions:)
    @NSManaged public func removeFromChoreCompletions(_ values: NSSet)

}

extension Chore : Identifiable {

}
