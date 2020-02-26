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
    
    var dataRequestPersons: Dictionary<String, ResultsStat>? {
        didSet{
            print("dataRequest update")
            setFilteredData()
        }
    }
    
    var recentViewPerson: Set<String> = [] // недавно просмотренные персонажи на экране детальной информации
    var filteredData: [String] = [] // данные по которым выполняется отображение поиска
    
    var timerSearchDelay: Timer? //таймер задержки определяющий окончания ввода пользователя
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        
        delegateNetwork = network
        network.delegateSendData = self
        
        
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
            recentViewPerson.insert(textName)
            StatViewController.sendData(searchPerson(namePerson: textName))
        }
        navigationController?.pushViewController(StatViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // remove the item from the data model
            recentViewPerson.remove(filteredData[indexPath.row])
            filteredData.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
