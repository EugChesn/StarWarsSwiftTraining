//
//  ProtocolsMain.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

protocol NetworkDelegate{
    func makeRequest(name: String) // сигнал к запросу к апи по переданной поисковой строке
    func getRecentPerson(recent: Set<String>) // запрос на получение данных недавно просмотренных персонажей
}

protocol DataRequestDelegate{
    func sendDataRequest(data: Dictionary<String, ResultsStat>?)
    func sendErrorRequest(error: String)
}
