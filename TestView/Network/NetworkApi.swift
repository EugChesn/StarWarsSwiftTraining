//
//  NetworkApi.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

fileprivate enum StateRequest{
    case Success
    case Error(String)
}

class NetworkApi{
    
    final let searchNameApi = "https://swapi.co/api/people/?search="
    let testApi = "https://swapi.co/api/people/1"
    
    private var dataRequest: Dictionary<String, ResultsStat> = [:] //  cash
    private var sessionData: [SearchJson] = []
    
    var delegateSendData: DataRequestDelegate?

    static let instance: NetworkApi = NetworkApi()
    private init(){}
    
    /*func getDifferentSearch() -> [String]? {
        let index = recentSearchText.count - 1
        if index > 0{
            guard let lastResult = dataRequest[recentSearchText[index]]?.results else {  return nil }
            guard let predResult = dataRequest[recentSearchText[index - 1]]?.results else {  return nil }
            
            var result: [String]?
            for item in lastResult{
                if predResult.contains(item){
                    result?.append(item.name)
                }
            }
            
            return result
            
        } else {
            return nil
        }
    }
    
    func differentCountResultOfLastRequest() -> Int{
        let index = recentSearchText.count - 1
        if index > 0{
            let result = (dataRequest[recentSearchText[index]]?.results?.count ?? 0) -           (dataRequest[recentSearchText[index - 1]]?.results?.count ?? 0)
            return result
        }
        else {
            return 0
        }
    }*/
    
    private func addRequestIntoDictionary(request: SearchJson) {
        if let result = request.results{
            for person in result{
                dataRequest.updateValue(person, forKey: person.name.lowercased())
            }
        }
    }
    
    private func getDictionaryForView(dataRequest: [SearchJson]) -> Dictionary<String, ResultsStat>? {
        var resDict: Dictionary<String, ResultsStat> = [:]
        for request in dataRequest{
            if let result = request.results{
                for person in result{
                    resDict.updateValue(person, forKey: person.name.lowercased())
                }
            }
        }
        return resDict
    }
    
    private func checkCashe(searchText: String) -> Dictionary<String, ResultsStat> {
        var resultPersons: Dictionary<String, ResultsStat>  = [:]
        for key in dataRequest.keys{
            if key.contains(searchText.lowercased()) {
                resultPersons[key] = dataRequest[key]
            }
        }
        return resultPersons
    }
    
    private func createUrlSearch(namePeople: String) -> URL?{
        let searchUrlStr = searchNameApi + namePeople
        if let url = URL(string: searchUrlStr){
            return url
        } else {
            return nil
        }
    }
    
    private func dataTask(session: URLSession, url: URL,
                          completion: @escaping (Any) -> (),
                          handlerError: @escaping (StateRequest) -> ()){
        
        var urlReq = URLRequest(url: url,
                                      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                      timeoutInterval: 10)
        urlReq.httpMethod = "GET"
        session.dataTask(with: urlReq) { (data, response, error) in
            
            if let error = error{
                handlerError(.Error(error.localizedDescription))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse{
                if !(200...299).contains(httpResponse.statusCode){
                    handlerError(.Error("Response code: \(httpResponse.statusCode)"))
                    return
                }
            }
            
            if let data = data{
                do{
                    let jsonTest = try JSONDecoder().decode(SearchJson.self, from: data)
                    self.sessionData.append(jsonTest)
                    completion(jsonTest)
                    self.addRequestIntoDictionary(request: jsonTest) // to cash
                    
                }catch let err{
                    handlerError(.Error(err.localizedDescription))
                }
                
            }
            
        } .resume()
    }
    
    private func createSession(namePeople: String){
        guard let url = createUrlSearch(namePeople: namePeople) else { return }
        let session = URLSession.shared
        
        func handlerError(state: StateRequest){
            switch state {
            case .Error(let msg):
                delegateSendData?.sendErrorRequest(error: msg)
                break
            case .Success:
                break
            }
        }
        
        func handler(jsonInput: Any){
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
    
    private func getApi(namePeople: String){
        let cashePerson = checkCashe(searchText: namePeople)
        
        if true{ //if cashePerson.isEmpty{
            createSession(namePeople: namePeople)
        } else {
            self.delegateSendData?.sendDataRequest(data: cashePerson)
        }
        
    }
}

extension NetworkApi: NetworkDelegate{
    func makeRequest(name: String){
        getApi(namePeople: name)
    }
    
    func getRecentPerson(recent: Set<String>){
        let keys = dataRequest.keys
        var result: Dictionary<String, ResultsStat> = [:]
        for item in recent{
            if keys.contains(item){
                result[item] = dataRequest[item]
            }
        }
        delegateSendData?.sendDataRequest(data: result)
    }
}
