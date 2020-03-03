//
//  ModelDataPerson.swift
//  StarsWar
//
//  Created by Евгений on 03.03.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import Foundation

class ModelDataPerson {
    private var dataRequest: [String: ResultsStat] = [:]
    static let shared: ModelDataPerson = ModelDataPerson()
    private init() { }
    func getPerson(recent: Set<String>) -> [String: ResultsStat] {
        let keys = dataRequest.keys
        var result: [String: ResultsStat] = [:]
        for item in recent {
            if keys.contains(item) {
                result[item] = dataRequest[item]
            }
        }
        return result
    }
    func checkPerson(recent: String) -> ResultsStat? {
        return dataRequest[recent]
    }
    func loadPerson(persons: [Person]) -> [String: ResultsStat] {
        for item in persons {
            let stat = ResultsStat(person: item)
            dataRequest.updateValue(stat, forKey: stat.name)
        }
        return dataRequest
    }
    func addRequestIntoDictionary(request: SearchJson) {
        if let result = request.results {
            for person in result {
                dataRequest.updateValue(person, forKey: person.name)
            }
        }
    }

    func getDictionaryForView(dataRequest: [SearchJson]) -> [String: ResultsStat]? {
        var resDict: [String: ResultsStat] = [:]
        for request in dataRequest {
            if let result = request.results {
                for person in result {
                    resDict.updateValue(person, forKey: person.name)
                }
            }
        }
        return resDict
    }
    func checkCashe(searchText: String) -> [String: ResultsStat] {
        var resultPersons: [String: ResultsStat] = [:]
        for key in dataRequest.keys {
            if key.contains(searchText) {
                resultPersons[key] = dataRequest[key]
            }
        }
        return resultPersons
    }
}
