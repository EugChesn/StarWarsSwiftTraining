//
//  ModelDataPerson.swift
//  StarsWar
//
//  Created by Евгений on 03.03.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import Foundation
import Reachability

protocol SearchPerson: class {
    func searchPerson(search: String,
                      completion: @escaping ([String]) -> Void,
                      failure: @escaping (String) -> Void)
}

protocol DatabaseRecentPerson: class {
    func setPersonsToDataBase(name: String)
    func loadPersonFromDataBase(completion: @escaping ([String]) -> Void)
    func setRecentViewPerson(name: String)
    func removeRecentPerson(name: String)
}

class ModelDataPerson {
    private var database = DataBase.instanse
    private var network = NetworkApi.instance
    private var reachability: Reachability?
    private var checkConnection: Bool = true
    private var dataRequest: [String: ResultsStat] = [:] //общий кеш полученный персонажей во время работы и
                                                        // загруженных из базы
    private var viewPersonsDataCore: [String] = []
    static let shared: ModelDataPerson = ModelDataPerson()
    private init() {
        do {
            try self.reachability = Reachability()
            addObserverStateConnection()
        } catch let error {
            reachability = nil
            print(error.localizedDescription)
        }
    }
    private func addObserverStateConnection() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)),
                                               name: .reachabilityChanged, object: reachability)
        do {
          try reachability?.startNotifier()
        } catch {
          print("could not start reachability notifier")
        }
    }
    @objc func reachabilityChanged(note: Notification) {
        guard let reachability = note.object as? Reachability else { return }
        switch reachability.connection {
        case .wifi, .cellular:
            checkConnection = true
        case .unavailable:
            checkConnection = false
        default:
            break
        }
    }
    func getRecentPerson() -> [String] {
        return viewPersonsDataCore
    }
    func getInfoAboutPerson(name: String) -> ResultsStat? {
        return dataRequest[name.lowercased()]
    }
    private func loadPerson(persons: [Person]) -> [String] {
        for item in persons {
            let stat = ResultsStat(person: item)
            dataRequest.updateValue(stat, forKey: stat.name.lowercased())
        }
        viewPersonsDataCore = Array(dataRequest.keys)
        return viewPersonsDataCore
    }
    private func getPerson(recent: Set<String>) -> [String: ResultsStat] {
        let keys = dataRequest.keys
        var result: [String: ResultsStat] = [:]
        for item in recent {
            if keys.contains(item) {
                result[item] = dataRequest[item]
            }
        }
        return result
    }
    private func addRequestIntoDictionary(request: SearchJson) {
        if let result = request.results {
            for person in result {
                dataRequest.updateValue(person, forKey: person.name.lowercased())
            }
        }
    }
    private func filteredDataRequest(request: SearchJson) -> [String] {
        var filtered = [String]()
        if let result = request.results {
            result.forEach { filtered.append($0.name.lowercased()) }
        }
        return filtered
    }

    private func checkCashe(searchText: String) -> [String] {
        var resultPersons: [String] = []
        for key in dataRequest.keys {
            if key.contains(searchText.lowercased()) {
                resultPersons.append(key)
            }
        }
        return resultPersons
    }
}
extension ModelDataPerson: SearchPerson {
    func searchPerson(search: String,
                      completion: @escaping ([String]) -> Void,
                      failure: @escaping (String) -> Void) {
        if checkConnection {
            network.dataTask(search: search, completion: { [weak self] (data) in
            guard let strongSelf = self else { return }
                if data.count != 0 {
                    strongSelf.addRequestIntoDictionary(request: data)
                    completion(strongSelf.filteredDataRequest(request: data))
                } else {
                    failure(StateView.noSearchResults)
                }
            }) { (error) in
                failure(error)
            }
        } else {
            completion(checkCashe(searchText: search))
            failure(StateView.noConection)
        }
    }
}

extension ModelDataPerson: DatabaseRecentPerson {
    func setPersonsToDataBase(name: String) {
        guard let person = dataRequest[name.lowercased()] else { return }
        database.saveCoreData(recent: person)
    }
    func loadPersonFromDataBase(completion: @escaping ([String]) -> Void) {
        database.loadCoreData(completion: { [weak self] (data) in
            guard let strongSelf = self else { return }
            completion(strongSelf.loadPerson(persons: data))
        })
    }
    func setRecentViewPerson(name: String) {
        if !viewPersonsDataCore.contains(name) {
            viewPersonsDataCore.append(name)
        }
    }
    func removeRecentPerson(name: String) {
        viewPersonsDataCore.removeAll {$0 == name}
        database.deleteCoreData(name: name)
    }
}
