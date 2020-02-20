//
//  TableViewController.swift
//  TestView
//
//  Created by Евгений on 11.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

class TableViewController : UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let network = NetworkApi()
    var delegateNetwork: NetworkDelegate?
    
    var data: [String] = [] // исходные данные таблицы
    var filteredData: [String] = [] // данные по которым выполняется фильтр отображения
    
    var timerSearchDelay: Timer? //таймер задержки определяющий окончания ввода пользователя
    
    var dataRequest: SearchJson? // данные полученные от api на основе введенного текста в поиск
    {
        didSet{
            print("dataRequest update")
            parseRequest()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        delegateNetwork = network
        network.delegateSendData = self
        filteredData = data
        
        //Для выключения клавиатуры
        let tapScreen = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapScreen.cancelsTouchesInView = false
        view.addGestureRecognizer(tapScreen)
    }
    
    @objc func dismissKeyboard(sender: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    private func registerTableViewCells (){
        let cell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        self.tableView.register(cell, forCellReuseIdentifier: "CustomTableViewCell")
    }
    
    private func parseRequest(){
        var tmpRes: [String] = []
        if let results = dataRequest?.results{
            for itemResult in results{
                tmpRes.append(itemResult.name)
            }
            filteredData.append(contentsOf: tmpRes)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                
                // Insert need to add!!!
                /*var indexPath = [IndexPath]()
                for i in 0 ..< tmpRes.count {
                    let index = IndexPath(row: i, section: 0)
                    indexPath.append(index)
                }
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: indexPath, with: .automatic)
                /*self.tableView.insertRows(at: [IndexPath(row: tmpRes.count - 1, section: 0)], with: .automatic)*/
                self.tableView.endUpdates()*/
            }
        }
    }
    private func parseRequest(namePerson:String)->[ResultsStat]?{
        var resultStat : [ResultsStat]?
        if let dataReq = dataRequest{
            guard let statPerson = dataReq.results else { return nil}
            resultStat = statPerson.filter({
                $0.name == namePerson
            })
        }
        return resultStat
    }
    
    private func checkDuplicateData(namePerson: String) ->Bool{
        let result = data.filter({
            $0 != namePerson
        })
        if result.count == data.count{
            return true
        } else{
            return false
        }
    }

    //Нажатие на ячейку таблицы переход к экрану детайльной информации
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let StatViewController = storyboard.instantiateViewController(withIdentifier: "Stat") as? DetailsController else {return}
        
        self.tableView.cellForRow(at: indexPath)?.isSelected = false
    
        if let cell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell{
            guard let textName = cell.textLabelPerson.text else { return }
            StatViewController.sendData(parseRequest(namePerson: textName))
            
            if checkDuplicateData(namePerson: textName){
                data.append(textName)
                searchBar.text = nil
                filteredData = data
                tableView.reloadData()
            }
        }
        navigationController?.pushViewController(StatViewController, animated: true)
    }
}
