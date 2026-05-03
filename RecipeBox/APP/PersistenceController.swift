//
//  PersistenceController.swift
//  RecipeBox
//
//  Created by Jyoti Purohit on 02/05/26.
//

import CoreData
import CloudKit
import UIKit

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "RecipeBox")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Use App Group so the widget can read the same store
            guard let appGroupURL = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: "group.com.chetan.RecipeBox") else {
                fatalError("App Group not configured")
            }
            let storeURL = appGroupURL.appendingPathComponent("RecipeBox.sqlite")
            let storeDescription = NSPersistentStoreDescription(url: storeURL)

            // Enable history tracking for background context merging (no CloudKit required)
            storeDescription.setOption(true as NSNumber,
                                      forKey: NSPersistentHistoryTrackingKey)
            storeDescription.setOption(true as NSNumber,
                                      forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

            container.persistentStoreDescriptions = [storeDescription]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }

        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save(context: NSManagedObjectContext? = nil) {
        let context = context ?? viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
        }
    }
    
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
