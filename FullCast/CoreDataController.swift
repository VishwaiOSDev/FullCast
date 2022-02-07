//
//  CoreDataController.swift
//  FullCast
//
//  Created by Vishwa  R on 06/02/22.
//

import CoreData

final class CoreDataController {
    
    private let container : NSPersistentContainer
    static let shared = CoreDataController()
    var viewContext : NSManagedObjectContext {
        return container.viewContext
    }
    
    private init() {
        container = NSPersistentContainer(name: "FullCast")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving data in CoreData", error.localizedDescription)
        }
    }
    
    func fetchAllRecordings() -> [Recording]? {
        let request : NSFetchRequest<Recording> = Recording.fetchRequest()
        let dateSorting = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [dateSorting]
        do {
            let recordings = try viewContext.fetch(request)
            return recordings
        } catch {
            print("Error fetching data from CoreData \(error.localizedDescription)")
            return nil
        }
    }
}

