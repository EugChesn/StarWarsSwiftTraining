//
//  NetworkApi.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import CoreData
import UIKit

class NetworkApi {
    private enum StateRequest {
        case success
        case error(String)
    }
    final let searchNameApi = "https://swapi.co/api/people/?search="
    // Общее хранилище(ключ имя персонажа);
    // Сюда сгружаются данные из БД и кешируется сетевые запросы
    private var dataRequest: [String: ResultsStat] = [:]
    // данные за одну сессию(в случае с множеством запросов к api с переходом по next)
    private var sessionData: [SearchJson] = []
    var delegateSendData: DataRequestDelegate?

    static let instance: NetworkApi = NetworkApi()
    private var checkConnection: Bool = true
    private func addRequestIntoDictionary(request: SearchJson) {
        if let result = request.results {
            for person in result {
                dataRequest.updateValue(person, forKey: person.name)
            }
        }
    }

    private func getDictionaryForView(dataRequest: [SearchJson]) -> [String: ResultsStat]? {
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
    private func checkCashe(searchText: String) -> [String: ResultsStat] {
        var resultPersons: [String: ResultsStat] = [:]
        for key in dataRequest.keys {
            if key.contains(searchText) {
                resultPersons[key] = dataRequest[key]
            }
        }
        return resultPersons
    }
    private func createUrlSearch(namePeople: String) -> URL? {
        let searchUrlStr = searchNameApi + namePeople
        if let url = URL(string: searchUrlStr) {
            return url
        } else {
            return nil
        }
    }
    private func dataTask(session: URLSession, url: URL,
                          completion: @escaping (Any) -> Void,
                          handlerError: @escaping (StateRequest) -> Void) {
        var urlReq = URLRequest(url: url,
                                      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                      timeoutInterval: 10)
        urlReq.httpMethod = "GET"
        session.dataTask(with: urlReq) { (data, response, error) in
            if let error = error {
                handlerError(.error(error.localizedDescription))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    handlerError(.error("Response code: \(httpResponse.statusCode)"))
                    return
                }
            }
            if let data = data {
                do {
                    let jsonTest = try JSONDecoder().decode(SearchJson.self, from: data)
                    self.sessionData.append(jsonTest)
                    completion(jsonTest)
                    self.addRequestIntoDictionary(request: jsonTest) // to cash
                } catch let err {
                    handlerError(.error(err.localizedDescription))
                }
            }
        } .resume()
    }
    private func createSession(namePeople: String) {
        guard let url = createUrlSearch(namePeople: namePeople) else { return }
        let session = URLSession.shared
        func handlerError(state: StateRequest) {
            switch state {
            case .error(let msg):
                self.checkConnection = false
                delegateSendData?.sendErrorRequest(error: msg)
            case .success:
                break
            }
        }
        func handler(jsonInput: Any) {
            self.checkConnection = true
            guard let json = jsonInput as? SearchJson else { return }
            guard let urlStr = json.next else {
                self.delegateSendData?.sendDataRequest(data: getDictionaryForView(dataRequest: sessionData))
                self.sessionData = []
                return
            }
            guard let url = URL(string: urlStr) else { return }
            dataTask(session: session, url: url, completion: handler(jsonInput:), handlerError: handlerError(state:))
        }
        dataTask(session: session, url: url, completion: handler(jsonInput:), handlerError: handlerError(state:))
    }
    private func getApi(namePeople: String) {
        if checkConnection {
            createSession(namePeople: namePeople)
        } else {
            let cashePerson = checkCashe(searchText: namePeople)
            self.delegateSendData?.sendDataRequest(data: cashePerson)
        }
    }
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
                if let dataReq = dataRequest[recent] {
                    var person = statToPerson(stat: dataReq)
                    CoreDataManager.shared.saveContext()
                }
            }
        }
    }
    private func loadCoreData() {
        let obj = CoreDataManager.shared.getFetchAllPerson(entityName: String(describing: Person.self)) as? [Person]
        if let persons = obj {
            for item in persons {
                let stat = ResultsStat(person: item)
                dataRequest.updateValue(stat, forKey: stat.name)
            }
            delegateSendData?.sendDataBase(data: dataRequest)
        }
    }
}

extension NetworkApi: NetworkDelegate {
    func makeRequest(name: String) {
        getApi(namePeople: name)
    }
    func getRecentPerson(recent: Set<String>) {
        let keys = dataRequest.keys
        var result: [String: ResultsStat] = [:]
        for item in recent {
            if keys.contains(item) {
                result[item] = dataRequest[item]
            }
        }
        delegateSendData?.sendDataRequest(data: result)
    }
    func getRecentPersonDataBase() {
        loadCoreData()
    }
    func setRecentPersonDataBase(recent: String) {
        saveCoreData(recent: recent)
    }
}
