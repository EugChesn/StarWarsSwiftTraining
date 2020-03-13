//
//  DataBase.swift
//  StarsWar
//
//  Created by Евгений on 03.03.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import Foundation

protocol actionDatabase: class {
    func saveCoreData(recent: ResultsStat)
    func loadCoreData(completion: @escaping ([Person]) -> Void)
    func deleteCoreData(name: String)
}

class DataBase: actionDatabase {
    static let instanse: DataBase = DataBase()
    private init() {}
    func saveCoreData(recent: ResultsStat) {
        func statToPerson(stat: ResultsStat) -> Person {
            let person = Person()
            person.name = stat.name
            person.height = Int32(stat.height) ?? 0
            person.mass = Int32(stat.mass) ?? 0
            person.gender = stat.gender
            person.color_eyes = stat.eyeColor
            person.color_hair = stat.hairColor
            person.color_skin = stat.skinColor
            person.year_birth = stat.birthYear
            return person
        }
        let countRecent = CoreDataManager.shared.countObjectRequest(entityName: "Person", filterKey: recent.name)
        if let count = countRecent {
            if count < 1 {
                var person = statToPerson(stat: recent)
                CoreDataManager.shared.saveContext()
            }
        }
    }
    func loadCoreData(completion: @escaping ([Person]) -> Void) {
        let objResult = CoreDataManager.shared.getFetchAllPerson(entityName: String(describing: Person.self)) as? [Person]
        if let result = objResult {
            completion(result)
        }
    }
    func deleteCoreData(name: String) {
        CoreDataManager.shared.deleteObject(entityName: "Person", filterKey: name)
    }
}
