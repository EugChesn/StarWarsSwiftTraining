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
    var headerTable = "Star Wars"
    
    
    let network = NetworkApi.instance
    var delegateNetwork: NetworkDelegate?
    
    //данные пришедщие от апи по последнему запросу
    var dataRequestPersons: Dictionary<String, ResultsStat>? {
        didSet{
            print("dataRequest update")
            setFilteredData()
        }
    }
    
    // недавно просмотренные персонажи на экране детальной информации
    var viewPersonsDataCore: Set<String> = []
    
    // данные по которым выполняется отображение поиска
    var filteredData: [String] = []
    
    //таймер задержки определяющий окончания ввода пользователя
    var timerSearchDelay: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        delegateNetwork = network
        network.delegateSendData = self
        
        // Загрузка данных из БД для первоначального отображения
        delegateNetwork?.getRecentPersonDataBase()
        filteredData = Array<String>(viewPersonsDataCore)
        
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
        tableView.register(cell, forCellReuseIdentifier: "CustomTableViewCell")
    }
    
    private func setFilteredData(){
        var tmpRes: [String] = []
        if let results = dataRequestPersons{
            for name in results.keys{
                tmpRes.append(name)
            }
        }
        filteredData = tmpRes
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func searchPerson(namePerson: String) -> ResultsStat? {
        if let person = dataRequestPersons{
            return person[namePerson]
        }
        else {
            return nil
        }
    }

    //Нажатие на ячейку таблицы переход к экрану детайльной информации
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let StatViewController = storyboard.instantiateViewController(withIdentifier: "Stat") as? DetailsController else {return}
        
        tableView.deselectRow(at: indexPath, animated: false)
        
    
        if let cell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell{
            guard let textName = cell.textLabelPerson.text else { return }
            
            viewPersonsDataCore.insert(textName)
            delegateNetwork?.setRecentPersonDataBase(recent: textName)
            
            StatViewController.sendData(searchPerson(namePerson: textName))
        }
        navigationController?.pushViewController(StatViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let cell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell{
                guard let textName = cell.textLabelPerson.text else { return }
                CoreDataManager.shared.deleteObject(entityName: "Person", filterKey: textName)
            }
            
            // remove the item from the data model
            viewPersonsDataCore.remove(filteredData[indexPath.row])
            CoreDataManager.shared.deleteObject(entityName: "Person", filterKey:filteredData[indexPath.row])
            filteredData.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
