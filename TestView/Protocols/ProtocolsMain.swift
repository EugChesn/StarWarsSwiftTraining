//
//  ProtocolsMain.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

protocol Network{
    func makeRequest(name: String)
}

protocol sendDataRequest{
    func sendDataRequest(data: SearchJson)
}
