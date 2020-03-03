//
//  TableViewController.swift
//  TestView
//
//  Created by Евгений on 11.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    enum StateView {
        static let search = "Search results"
        static let noSearchResults = "Not found"
        static let recent = "Recent person"
    }
    var headerTable = "Star Wars"
    let network = NetworkApi.instance
    let dataBase = DataBase.instanse
    var delegateNetwork: NetworkDelegate?
    var delegateDataBase: DataBaseDelegate?
    //данные пришедщие от апи по последнему запросу
    var dataRequestPersons: [String: ResultsStat]? {
        didSet {
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
        bindingService()
        // Загрузка данных из БД для первоначального отображения
        delegateDataBase?.getRecentPersonDataBase()
        filteredData = [String](viewPersonsDataCore)
    }
    private func bindingService() {
        delegateNetwork = network
        delegateDataBase = dataBase
        network.delegateSendData = self
        dataBase.delegateSendData = self
    }
    private func registerTableViewCells() {
        let cell = UINib(nibName: "CustomTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "CustomTableViewCell")
    }
    private func setFilteredData() {
        var tmpRes: [String] = []
        if let results = dataRequestPersons {
            for name in results.keys {
                tmpRes.append(name)
            }
        }
        filteredData = tmpRes
        DispatchQueue.main.async {
            self.stopSpinner()
        }
    }
    private func searchPerson(namePerson: String) -> ResultsStat? {
        if let person = dataRequestPersons {
            return person[namePerson]
        } else {
            return nil
        }
    }
    func startSpinner() {
        spinner.isHidden = false
        spinner.startAnimating()
        filteredData = []
        tableView.reloadData()
    }
    func stopSpinner() {
        spinner.isHidden = true
        spinner.stopAnimating()
        tableView.reloadData()
    }

    //Нажатие на ячейку таблицы переход к экрану детайльной информации
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let statViewController = storyboard.instantiateViewController(withIdentifier: "Stat")
            as? DetailsController else {return}
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
            guard let textName = cell.textLabelPerson.text else { return }
            viewPersonsDataCore.insert(textName)
            delegateDataBase?.setRecentPersonDataBase(recent: textName)
            statViewController.sendData(searchPerson(namePerson: textName))
        }
        navigationController?.pushViewController(statViewController, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let cell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
                guard let textName = cell.textLabelPerson.text else { return }
                CoreDataManager.shared.deleteObject(entityName: "Person", filterKey: textName)
            }
            // remove the item from the data model
            viewPersonsDataCore.remove(filteredData[indexPath.row])
            CoreDataManager.shared.deleteObject(entityName: "Person", filterKey: filteredData[indexPath.row])
            filteredData.remove(at: indexPath.row)
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
