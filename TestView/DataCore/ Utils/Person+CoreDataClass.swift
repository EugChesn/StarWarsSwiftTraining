//
//  Person+CoreDataClass.swift
//  StarsWar
//
//  Created by Евгений on 28.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Person)
public class Person: NSManagedObject {
    convenience init() {
        self.init(entity: CoreDataManager.shared.getEntityForName("Person"), insertInto: CoreDataManager.shared.persistentContainer.viewContext)
    }
    
}
