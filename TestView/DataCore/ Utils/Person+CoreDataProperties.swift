//
//  Person+CoreDataProperties.swift
//  StarsWar
//
//  Created by Евгений on 28.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var color_eyes: String?
    @NSManaged public var color_hair: String?
    @NSManaged public var color_skin: String?
    @NSManaged public var gender: String?
    @NSManaged public var height: Int32
    @NSManaged public var mass: Int32
    @NSManaged public var name: String?
    @NSManaged public var year_birth: String?

}
