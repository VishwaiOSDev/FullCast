//
//  Recording+CoreDataProperties.swift
//  FullCast
//
//  Created by Vishwa  R on 08/02/22.
//
//

import Foundation
import CoreData


extension Recording {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recording> {
        return NSFetchRequest<Recording>(entityName: "Recording")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var fileName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var toCategory: Category?
    
    public var wrappedfileName : String {
        fileName ?? "Unknown"
    }
    
}

extension Recording : Identifiable {

}
