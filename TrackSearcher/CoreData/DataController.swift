//
//  DataController.swift
//  TrackSearcher
//
//  Created by Евгений on 14.04.17.
//  Copyright © 2017 Евгений. All rights reserved.
//

import UIKit
import CoreData

class DataController {

    static let instance = DataController {}

    var managedObjectContext: NSManagedObjectContext

    private init(completionClosure: @escaping () -> Void) {
        guard let modelURL = Bundle.main.url(forResource: "ITunesSearch", withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }

        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)

        managedObjectContext = NSManagedObjectContext(
            concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc

        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        queue.async {
            guard let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
                fatalError("Unable to resolve document directory")
            }
            let storeURL = docURL.appendingPathComponent("DataModel.sqlite")
            do {

                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil,
                                           at: storeURL, options: nil)
                DispatchQueue.main.sync(execute: completionClosure)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }

    func saveContext() {
        if (managedObjectContext.hasChanges) == (true) {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
