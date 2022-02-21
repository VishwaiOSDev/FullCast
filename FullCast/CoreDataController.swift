//
//  CoreDataController.swift
//  FullCast
//
//  Created by Vishwa  R on 06/02/22.
//

import CoreData

enum RemainderType {
    case remind(Date)
    case cancel
}

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
        self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            }
            catch {
                print("Error saving data in CoreData", error.localizedDescription)
            }
        }
    }
    
    func updateReminderForRecording(at id: UUID, remainderType: RemainderType) -> Bool {
        let request: NSFetchRequest<Recording> = Recording.fetchRequest()
        let idFiltering = NSPredicate(format: "id == %@", id as CVarArg)
        request.predicate = idFiltering
        do {
            let recording = try viewContext.fetch(request)[0]
            switch remainderType {
            case .remind(let date):
                recording.reminderEnabled = true
                recording.whenToRemind = date
            case .cancel:
                recording.reminderEnabled = false
                recording.whenToRemind = nil
            }
            save()
            return true
        } catch {
            print("Error while fetching record for updating remainder \(error.localizedDescription)")
            return false
        }
    }
    
    func fetchAllRecordings(of selectedCategory: Category) -> [Recording]? {
        let request : NSFetchRequest<Recording> = Recording.fetchRequest()
        let cateogoryFiltering = NSPredicate(format: "toCategory.categoryName MATCHES %@", selectedCategory.wrappedCategoryName)
        request.predicate = cateogoryFiltering
        let dateSorting = NSSortDescriptor(key: "createdAt", ascending: false)
        request.sortDescriptors = [dateSorting]
        do {
            let recordings = try viewContext.fetch(request)
            checkNotificationUpdates(for: recordings)
            save()
            return recordings
        } catch {
            print("Error fetching data from CoreData \(error.localizedDescription)")
            return nil
        }
    }
    
    private func checkNotificationUpdates(for recordings: [Recording]) {
        recordings.forEach { recording in
            if let whenDate = recording.whenToRemind {
                if whenDate <= Date() {
                    recording.whenToRemind = nil
                    recording.reminderEnabled = false
                }
            }
        }
    }
    
    func deleteRecording(recording: Recording) {
        viewContext.delete(recording)
        save()
    }
    
}


//MARK: - UITesting CoreData Stack

final class TestCoreDataStack {
    lazy var presistentContainer: NSPersistentContainer = {
        var description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "FullCast")
        container.persistentStoreDescriptions = [description]
        //        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { _ , error in
            if let error = error as NSError? {
                fatalError("Unable to setup CoreData in-memory \(error)")
            }
        }
        return container
    }()
    
    
    func addFolderToDataBase(folderName: String) {
        let context = presistentContainer.newBackgroundContext()
        context.performAndWait {
            let folder = NSEntityDescription.insertNewObject(forEntityName: "Category", into: context) as! Category
            folder.categoryName = folderName
            try? context.save()
        }
    }
    
    func fetchFolderWithName(folderName: String) -> [Category] {
        let context = presistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", folderName)
        var folder = [Category]()
        context.performAndWait {
            let details = try! context.fetch(fetchRequest)
            folder = details
        }
        return folder
    }
    
    func fetchAllFolders() -> [Category] {
        let context = presistentContainer.viewContext
        var allCategories = [Category]()
        context.performAndWait {
            let data = try! context.fetch(Category.fetchRequest())
            allCategories = data
        }
        return allCategories
    }
    
}

