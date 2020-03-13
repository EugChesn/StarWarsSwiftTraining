//
//  NetworkApi.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit
import Reachability

class NetworkApi {
    enum StateRequest {
        case success
        case error(String)
    }
    final let searchNameApi = "https://swapi.co/api/people/?search="
    static let instance: NetworkApi = NetworkApi()
    private init() {}

    private func createUrlSearch(namePeople: String) -> URL? {
        let searchUrlStr = searchNameApi + namePeople
        if let url = URL(string: searchUrlStr) {
            return url
        } else {
            return nil
        }
    }
    func dataTask(search: String,
                  completion: @escaping (SearchJson) -> Void,
                  handlerError: @escaping (String) -> Void) {

        let session = URLSession.shared
        guard let url = createUrlSearch(namePeople: search) else {  return }
        var urlReq = URLRequest(url: url,
                                      cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                      timeoutInterval: 5)
        urlReq.httpMethod = "GET"
        session.dataTask(with: urlReq) { (data, response, error) in
            if let error = error {
                handlerError((error.localizedDescription))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    handlerError(("Response code: \(httpResponse.statusCode)"))
                    return
                }
            }
            if let data = data {
                do {
                    let jsonTest = try JSONDecoder().decode(SearchJson.self, from: data)
                    completion(jsonTest)
                } catch let err {
                    handlerError((err.localizedDescription))
                }
            }
        }.resume()
    }
}
