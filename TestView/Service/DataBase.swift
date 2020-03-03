//
//  DataBase.swift
//  StarsWar
//
//  Created by Евгений on 03.03.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import Foundation

class DataBase {
    private var modelRequest = ModelDataPerson.shared
    static let instanse: DataBase = DataBase()
    private init() {}
    var delegateSendData: DataRequestDelegate?
    private func saveCoreData(recent: String) {
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
        let countRecent = CoreDataManager.shared.countObjectRequest(entityName: "Person", filterKey: recent)
        if let count = countRecent {
            if count < 1 {
                guard let dataReq = modelRequest.checkPerson(recent: recent) else { return }
                var person = statToPerson(stat: dataReq)
                CoreDataManager.shared.saveContext()
            }
        }
    }
    private func loadCoreData() {
        let obj = CoreDataManager.shared.getFetchAllPerson(entityName: String(describing: Person.self)) as? [Person]
        if let persons = obj {
            delegateSendData?.sendDataBase(data: modelRequest.loadPerson(persons: persons))
        }
    }
}

extension DataBase: DataBaseDelegate {
    func getRecentPersonDataBase() {
        loadCoreData()
    }
    func setRecentPersonDataBase(recent: String) {
        saveCoreData(recent: recent)
    }
}
