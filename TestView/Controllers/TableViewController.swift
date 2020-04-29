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
    
    let heightRow: CGFloat = 50
    let heightHeaderSection: CGFloat = 50
    var model = ModelDataPerson.shared
    var headerTable = StateView.launch
    var timerSearchDelay: Timer?

    // данные по которым выполняется отображение поиска
    var filteredData: [String] = [] {
        willSet(newValue) {
            if !newValue.isEmpty {
                setFilteredData()
            } 
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellType: CustomTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        // Загрузка данных из БД для первоначального отображения
        model.loadPersonFromDataBase(completion: {[weak self] data in
            guard let strongSelf = self else { return }
            strongSelf.filteredData = data
        })
    }

    private func setFilteredData() {
        DispatchQueue.main.async {
            self.stopSpinner()
        }
    }
    func startSpinner() {
        setHeaderTable(state: StateView.search)
        spinner.isHidden = false
        spinner.startAnimating()
        filteredData = []
        reloadData()
    }
    func stopSpinner() {
        spinner.isHidden = true
        spinner.stopAnimating()
        reloadData()
    }
    private func reloadData() {
        tableView.beginUpdates()
        tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableView.endUpdates()
    }
    func setRecent() {
        headerTable = StateView.recent
        filteredData = model.getRecentPerson()
        if filteredData.isEmpty {
            stopSpinner()
        } else {
            reloadData()
        }
    }
    private func setHeaderTable(state: String) {
        headerTable = state
    }
    private func createAlert(error: NetworkRequestError) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .actionSheet)
        alert.view.alpha = 6
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true)
        }
    }
    func alertError(error: NetworkRequestError) {
        DispatchQueue.main.async {
            self.stopSpinner()
            switch error {
            case .noConnection:
                self.setHeaderTable(state: StateView.noConection)
            case .noSearchResult:
                self.setHeaderTable(state: StateView.noSearchResults)
            case .errorRequest:
                self.createAlert(error: .errorRequest)
            case .jsonDecode:
                self.createAlert(error: .errorRequest)
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let statViewController = storyboard.instantiateViewController(withIdentifier: "Stat")
            as? DetailsController else {return}
        tableView.deselectRow(at: indexPath, animated: false)
        if let cell = self.tableView.cellForRow(at: indexPath) as? CustomTableViewCell {
            guard let textName = cell.textLabelPerson.text else { return }
            model.setRecentViewPerson(name: textName)
            model.setPersonsToDataBase(name: textName)
            statViewController.sendData(model.getInfoAboutPerson(name: textName))
        }
        searchBar.resignFirstResponder()
        navigationController?.present(statViewController, animated: true, completion: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            model.removeRecentPerson(name: filteredData[indexPath.row])
            filteredData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
