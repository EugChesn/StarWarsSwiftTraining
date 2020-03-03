//
//  Extensions.swift
//  TestView
//
//  Created by Евгений on 15.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTable
    }
    //Выставление настроек отображения заголовка таблицы
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header: UITableViewHeaderFooterView = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textAlignment = NSTextAlignment.center
        header.textLabel?.font = UIFont(name: "", size: 20)
        header.textLabel?.textColor = UIColor.systemBlue
    }
    //Создание кастомной ячейки таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell",
                                                    for: indexPath) as? CustomTableViewCell {
            cell.textLabelPerson.text = filteredData[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
}

extension TableViewController: DataRequestDelegate {
    func sendDataRequest(data: [String: ResultsStat]?) {
        if let dataExitst = data {
            if !dataExitst.isEmpty {
                headerTable = StateView.search
            } else {
                headerTable = StateView.noSearchResults
            }
            dataRequestPersons = dataExitst
        }
    }
    func sendErrorRequest(error: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: error, preferredStyle: .alert)
            alert.view.alpha = 6
            alert.view.layer.cornerRadius = 15
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                alert.dismiss(animated: true)
            }
        }
    }
    func sendDataBase(data: [String: ResultsStat]?) {
        if let dataExitst = data {
            dataRequestPersons = data
            for item in dataExitst {
                viewPersonsDataCore.insert(item.key)
            }
        }
    }
}

extension TableViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timerSearchDelay?.invalidate()
        timerSearchDelay = nil
        timerSearchDelay = Timer.scheduledTimer(timeInterval: 0.5, target: self,
                                                selector: #selector(self.doDelayedSearch),
                                                userInfo: searchText, repeats: false)
    }
    @objc func doDelayedSearch(_: Timer) {
        startSpinner()
        guard let info = timerSearchDelay?.userInfo as? String else { return }
        if !info.isEmpty {
            delegateNetwork?.makeRequest(name: info)
        } else {
            delegateNetwork?.getRecentPerson(recent: viewPersonsDataCore)
            headerTable = StateView.recent
            tableView.reloadData()
        }
        timerSearchDelay = nil
    }
}
