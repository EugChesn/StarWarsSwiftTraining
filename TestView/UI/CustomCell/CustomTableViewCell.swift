//
//  CustomTableViewCell.swift
//  TestView
//
//  Created by Евгений on 12.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    @IBOutlet weak var textLabelPerson: UILabel!
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            contentView.backgroundColor = UIColor .systemGray
            subviews.forEach { $0.superview?.backgroundColor = UIColor .systemGray }
        } else {
            contentView.backgroundColor = UIColor .systemBackground
            subviews.forEach { $0.superview?.backgroundColor = UIColor .systemBackground }
        }
    }
    override func prepareForReuse() {
        textLabelPerson.text = nil
    }
}
