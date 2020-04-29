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
    
    let heightHeaderSection: CGFloat = 50
    var statPerson: ResultsStat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(cellType: CustomDetailTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func sendData(_ anyData: Any?) {
        if let detailStruct = anyData as? ResultsStat {
            statPerson = detailStruct
        }
    }
}

extension DetailsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return heightHeaderSection
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: heightHeaderSection))

        let label = UILabel()
        label.frame = CGRect.init(x: 15, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Info"
        label.font = UIFont(name: "", size: 6)
        label.textColor = UIColor .systemBlue
        headerView.addSubview(label)

        return headerView
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statPerson?.details.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: CustomDetailTableViewCell.self, for: indexPath)
        let details = statPerson?.details[indexPath.row]
        cell.titleLabel?.text = details?.0
        cell.typeLabel?.text = details?.1
        return cell
    }
}
