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
    
    func countObjectRequest(entityName: String, filterKey: String) -> Int?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.predicate = NSPredicate(format: "name CONTAINS[cd] %@", filterKey)
        do{
            let count = try persistentContainer.viewContext.count(for: fetchRequest)
            return count
        }catch{
            print("error reqeust count")
        }
        return nil
    }
    
    func deleteObject(entityName: String, filterKey: String){
        let fetchRequestDel = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequestDel.predicate = NSPredicate(format: "name == %@", filterKey)
        do{
            let arrUsrObj = try persistentContainer.viewContext.fetch(fetchRequestDel)
            for usrObj in arrUsrObj as! [NSManagedObject] {
                 persistentContainer.viewContext.delete(usrObj)
            }
        }catch{
            print("error reqeust delete")
        }
        print(persistentContainer.viewContext.deletedObjects)
        
        saveContext()
    }
    
    func getFetchAllPerson(entityName: String) -> [Any]?{
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        do{
            let objPerson = try persistentContainer.viewContext.fetch(fetchRequest)
            return objPerson
        }catch{
            print("error reqeust all person")
        }
        return nil
    }

    // MARK: - Core Data stack
    func getFetchResultsController(entityName: String, sortDescriptorKey: String, filterKey: String?) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: sortDescriptorKey, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let filter = filterKey {
            fetchRequest.predicate = NSPredicate(format: "Person.name = %@", filter)
        }
        let fetchedResultsVc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultsVc
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ModelPerson")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
