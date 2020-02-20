//
//  RequestController.swift
//  TestView
//
//  Created by Евгений on 11.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit


class DetailsController : UIViewController{
    var statPerson: [ResultsStat]?
    
    @IBOutlet weak var namePerson: DataView!
    @IBOutlet weak var heightPerson: DataView!
    @IBOutlet weak var massPerson: DataView!
    @IBOutlet weak var hairColorPerson: DataView!
    @IBOutlet weak var skinColorPerson: DataView!
    @IBOutlet weak var eyeColorPerson: DataView!
    @IBOutlet weak var birthYearPerson: DataView!
    @IBOutlet weak var genderPerson: DataView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNameLabeLoad()
        setDataTextLabelLoad()
    }
    
    private func setNameLabeLoad(){
        namePerson.labelContent.text = "Name"
        heightPerson.labelContent.text = "Height"
        massPerson.labelContent.text = "Mass"
        hairColorPerson.labelContent.text = "Color hair"
        skinColorPerson.labelContent.text = "Color skin"
        eyeColorPerson.labelContent.text = "Color eyes"
        birthYearPerson.labelContent.text = "Year birth"
        genderPerson.labelContent.text = "Gender"
    }
    private func setDataTextLabelLoad(){
        if let stat = statPerson{
            namePerson.textFieldVar.text = stat[0].name
            heightPerson.textFieldVar.text = stat[0].height
            massPerson.textFieldVar.text = stat[0].mass
            hairColorPerson.textFieldVar.text = stat[0].hairColor
            skinColorPerson.textFieldVar.text = stat[0].skinColor
            eyeColorPerson.textFieldVar.text = stat[0].eyeColor
            birthYearPerson.textFieldVar.text = stat[0].birthYear
            genderPerson.textFieldVar.text = stat[0].gender
        }
    }
    
    func sendData(_ anyData: Any?) {
        if let detailStruct = anyData as? [ResultsStat] {
            statPerson = detailStruct
        }
    }
    
}

