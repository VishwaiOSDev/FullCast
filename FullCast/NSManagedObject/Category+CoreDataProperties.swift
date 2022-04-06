//
//  Category+CoreDataProperties.swift
//  FullCast
//
//  Created by Vishwa  R on 18/02/22.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var toRecording: NSSet?
    
    public var wrappedCategoryName : String {
            categoryName ?? "Unknown"
        }
        
    public var recordingArray: [Recording] {
        let set = toRecording as? Set<Recording> ?? []
        
        return set.sorted {
            $0.wrappedfileName < $1.wrappedfileName
        }
        
    }

}

// MARK: Generated accessors for toRecording
extension Category {

    @objc(addToRecordingObject:)
    @NSManaged public func addToToRecording(_ value: Recording)

    @objc(removeToRecordingObject:)
    @NSManaged public func removeFromToRecording(_ value: Recording)

    @objc(addToRecording:)
    @NSManaged public func addToToRecording(_ values: NSSet)

    @objc(removeToRecording:)
    @NSManaged public func removeFromToRecording(_ values: NSSet)

}

extension Category : Identifiable {

}
