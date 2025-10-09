//
//  ChoreCompletion+CoreDataProperties.swift
//  chorearoo
//
//  Created by Chase Caldwell on 10/8/25.
//
//

public import Foundation
public import CoreData


public typealias ChoreCompletionCoreDataPropertiesSet = NSSet

extension ChoreCompletion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChoreCompletion> {
        return NSFetchRequest<ChoreCompletion>(entityName: "ChoreCompletion")
    }

    @NSManaged public var approvedAt: Date?
    @NSManaged public var completedAt: Date?
    @NSManaged public var givingAmount: Double
    @NSManaged public var id: UUID?
    @NSManaged public var savingsAmount: Double
    @NSManaged public var spendingAmount: Double
    @NSManaged public var status: String?
    @NSManaged public var weekStartDate: Date?
    @NSManaged public var approvedBy: Parent?
    @NSManaged public var child: Child?
    @NSManaged public var chore: Chore?

}

extension ChoreCompletion : Identifiable {

}
