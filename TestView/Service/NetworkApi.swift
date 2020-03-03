//
//  NetworkApi.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

//import Alamofire
import UIKit

class NetworkApi {
    private enum StateRequest {
        case success
        case error(String)
    }
    final let searchNameApi = "https://swapi.co/api/people/?search="
    private var modelRequest = ModelDataPerson.shared
    // данные за одну сессию(в случае с множеством запросов к api с переходом по next)
    private var sessionData: [SearchJson] = []
    var delegateSendData: DataRequestDelegate?

    static let instance: NetworkApi = NetworkApi()
    private init() {}
    private var checkConnection: Bool = true

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
                    self.modelRequest.addRequestIntoDictionary(request: jsonTest)
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
                delegateSendData?.sendErrorRequest(error: msg)
            case .success:
                break
            }
        }
        func handler(jsonInput: Any) {
            guard let json = jsonInput as? SearchJson else { return }
            guard let urlStr = json.next else {
                self.delegateSendData?.sendDataRequest(data: modelRequest.getDictionaryForView(dataRequest: sessionData))
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
            let cashePerson = modelRequest.checkCashe(searchText: namePeople)
            self.delegateSendData?.sendDataRequest(data: cashePerson)
        }
    }
}

extension NetworkApi: NetworkDelegate {
    func makeRequest(name: String) {
        getApi(namePeople: name)
    }
    func getRecentPerson(recent: Set<String>) {
        let result = modelRequest.getPerson(recent: recent)
        delegateSendData?.sendDataRequest(data: result)
    }
}
