//
//  ModelJson.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

struct SearchJson : Codable {
    var count: Int
    var next: String?
    var previous : String?
    var results: [ResultsStat]?
}

struct ResultsStat : Codable {
    var name : String
    var height: String 
    var mass : String
    var hair_color : String
    var skin_color : String
    var eye_color : String
    var birth_year : String
    var gender : String 
}
