//
//  CoreDataManager.swift
//  StarsWar
//
//  Created by Евгений on 28.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared: CoreDataManager = CoreDataManager()
    private init() { }

    func getEntityForName(_ string: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: string, in: persistentContainer.viewContext)!
    }
    func countObjectRequest(entityName: String, filterKey: String) -> Int? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", filterKey)
        do {
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count
        } catch {
            print("error reqeust count")
        }
        return nil
    }
    func deleteObject(entityName: String, filterKey: String) {
        let fetchRequestDel = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequestDel.predicate = NSPredicate(format: "name == %@", filterKey)
        do {
            guard let arrUsrObj = try persistentContainer.viewContext.fetch(fetchRequestDel) as? [NSManagedObject]
                else { return }
            for usrObj in arrUsrObj {
                 persistentContainer.viewContext.delete(usrObj)
            }
        } catch {
            print("error reqeust delete")
        }
        print(persistentContainer.viewContext.deletedObjects)
        saveContext()
    }
    func getFetchAllPerson(entityName: String) -> [Any]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do {
            let objPerson = try persistentContainer.viewContext.fetch(fetchRequest)
            return objPerson
        } catch {
            print("error reqeust all person")
        }
        return nil
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ModelPerson")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
