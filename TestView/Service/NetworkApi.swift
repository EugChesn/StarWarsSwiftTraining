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
    final let searchNameApi = "https://swapi.co/api/people/?search="
    static let instance: NetworkApi = NetworkApi()
    private init() {}

    private func createUrlSearch(namePeople: String) -> URL? {
        return URL(string: searchNameApi + namePeople)
    }
    
    func dataTask(search: String, completion: @escaping (Result<SearchJson, NetworkRequestError>) -> Void) {
        let session = URLSession.shared
        guard let url = createUrlSearch(namePeople: search) else {  return }
        var urlReq = URLRequest(url: url,
                                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                timeoutInterval: 5)
        urlReq.httpMethod = "GET"
        session.dataTask(with: urlReq) { (data, response, error) in
            if error != nil {
                completion(.failure(.errorRequest))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if !(200...299).contains(httpResponse.statusCode) {
                    completion(.failure(.errorRequest))
                    return
                }
            }
            if let data = data {
                do {
                    let jsonTest = try JSONDecoder().decode(SearchJson.self, from: data)
                    completion(.success(jsonTest))
                } catch {
                    completion(.failure(.jsonDecode))
                }
            }
        }.resume()
    }
}
