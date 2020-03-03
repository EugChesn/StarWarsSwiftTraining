//
//  ProtocolsMain.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

protocol NetworkDelegate: class {
    // сигнал к запросу к апи по переданной поисковой строке
    func makeRequest(name: String)
    // запрос на получение данных недавно просмотренных персонажей
    func getRecentPerson(recent: Set<String>)
}

protocol DataBaseDelegate: class {
    // запрос на получении данных недавно просмотренных персонажей из базы
    func getRecentPersonDataBase()
    // сигнал добавить персонажа в базу
    func setRecentPersonDataBase(recent: String)
}

protocol DataRequestDelegate: class {
    // полученне данных сетевого запроса
    func sendDataRequest(data: [String: ResultsStat]?)
    // получение данных ошибки запроса
    func sendErrorRequest(error: String)
    // сигнал к отправке данных недавно просмотренного персонажа в базу данных
    func sendDataBase(data: [String: ResultsStat]?)
}
