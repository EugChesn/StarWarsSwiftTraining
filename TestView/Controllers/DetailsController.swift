//
//  RequestController.swift
//  TestView
//
//  Created by Евгений on 11.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var statPerson: ResultsStat?
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func registerTableViewCells() {
        let cell = UINib(nibName: "CustomDetailTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "DetailCell")
    }
    func sendData(_ anyData: Any?) {
        if let detailStruct = anyData as? ResultsStat {
            statPerson = detailStruct
        }
    }
}

extension DetailsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))

        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Info"
        label.font = UIFont(name: "", size: 6) // my custom font
        label.textColor = UIColor .systemBlue // my custom colour

        headerView.addSubview(label)

        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statPerson?.details.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell",
                                                    for: indexPath) as? CustomDetailTableViewCell {
            let details = statPerson?.details[indexPath.row]
            cell.titleLabel?.text = details?.0
            cell.typeLabel?.text = details?.1
            return cell
        }
        return UITableViewCell()
    }
}
