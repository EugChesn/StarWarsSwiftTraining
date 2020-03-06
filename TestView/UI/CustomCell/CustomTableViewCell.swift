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
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            contentView.backgroundColor = UIColor .systemGray
            for item in self.subviews {
                item.superview?.backgroundColor = UIColor .systemGray
            }
        } else {
            for item in self.subviews {
                item.superview?.backgroundColor = UIColor .systemBackground
            }
            self.contentView.backgroundColor = UIColor .systemBackground
        }
    }
    override func prepareForReuse() {
        textLabelPerson.text = nil
    }
}
