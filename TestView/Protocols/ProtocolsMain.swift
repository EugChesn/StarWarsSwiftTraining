//
//  ProtocolsMain.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

protocol NetworkDelegate{
    func makeRequest(name: String)
}

protocol DataRequestDelegate{
    func sendDataRequest(data: SearchJson)
}
