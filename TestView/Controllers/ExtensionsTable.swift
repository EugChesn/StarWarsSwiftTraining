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
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightRow
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return heightHeaderSection
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))

        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = headerTable
        label.font = UIFont(name: "", size: 6) // my custom font
        label.textColor = UIColor .systemBlue // my custom colour

        headerView.addSubview(label)

        return headerView
    }
    //Создание кастомной ячейки таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CustomTableViewCell.self, for: indexPath)
        cell.textLabelPerson.text = filteredData[indexPath.row]
        return cell
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
        searchBar.resignFirstResponder()
    }
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timerSearchDelay?.invalidate()
        timerSearchDelay = nil
        timerSearchDelay = Timer.scheduledTimer(timeInterval: 0.7, target: self,
                                                selector: #selector(self.doDelayedSearch),
                                                userInfo: searchText, repeats: false)
    }
    @objc func doDelayedSearch(_: Timer) {
        guard let info = timerSearchDelay?.userInfo as? String else { return }
        if !info.isEmpty {
            startSpinner()
            model.searchPerson(search: info, completion: { [weak self] result in
                guard let strongSelf = self else { return }
                switch result {
                case .success(let data):
                    strongSelf.filteredData = data
                case .failure(let error):
                    strongSelf.alertError(error: error)
                }
            })
        } else {
            setRecent()
        }
        timerSearchDelay = nil
    }
}
