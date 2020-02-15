//
//  NetworkApi.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import Foundation

class NetworkApi : Network{
    
    let searchNameApi = "https://swapi.co/api/people/?search="
    let testApi = "https://swapi.co/api/people/1"
    
    private var dataRequest : SearchJson?
    var delegateSendData: sendDataRequest?
    
    func makeRequest(name:String) {
         getApi(namePeople: name)
    }
    
    private func getApi(namePeople: String){
        let searchUrlStr = searchNameApi + namePeople
        guard let url = URL(string: searchUrlStr) else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let error = error{
                print(error)
                return
            }
            
            if let response = response {
                print(response)
            }
            
            if let data = data{
                print(data)
                
                do{
                    
                    let jsonTest = try JSONDecoder().decode(SearchJson.self, from: data)
                    print(jsonTest)
                    self.dataRequest = jsonTest
                    self.delegateSendData?.sendDataRequest(data: jsonTest)
                   
                }catch let err{
                    print(err)
                }
                
            }
        } .resume()
        
    }
}
