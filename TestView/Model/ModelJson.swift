//
//  ModelJson.swift
//  TestView
//
//  Created by Евгений on 14.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

struct SearchJson: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [ResultsStat]?
}

struct ResultsStat: Codable, Equatable {
    var name: String
    var height: String
    var mass: String
    var hairColor: String
    var skinColor: String
    var eyeColor: String
    var birthYear: String
    var gender: String
    init(person: Person) {
        name = person.name ?? ""
        height = String(person.height)
        mass = String(person.mass)
        hairColor = person.color_hair ?? ""
        skinColor = person.color_skin ?? ""
        eyeColor = person.color_eyes ?? ""
        birthYear = person.year_birth ?? ""
        gender = person.gender ?? ""
    }
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case height = "height"
        case mass = "mass"
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
        case gender = "gender"
    }
    var details: [(String, String)] {
        return [("Name", name),
        ("Height", height),
        ("Mass", mass),
        ("Hair color", hairColor),
        ("Skin color", skinColor),
        ("Birth year", birthYear),
        ("Gender", gender)]
    }
    static func == (left: ResultsStat, right: ResultsStat) -> Bool {
        return left.name == right.name
    }
}

enum StateView {
    static let launch = "Star Wars"
    static let search = "Search results"
    static let noSearchResults = "Not found"
    static let recent = "Recent person"
    static let noConection = "No Conection"
}
