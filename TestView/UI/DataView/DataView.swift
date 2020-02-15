//
//  TestView.swift
//  TestView
//
//  Created by Евгений on 11.02.2020.
//  Copyright © 2020 Евгений. All rights reserved.
//

import UIKit

class DataView : UIView{
    
    @IBOutlet weak var labelContent: UILabel!
    @IBOutlet weak var textFieldVar: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle.init(for: DataView.self)
        if let viewsToAdd = bundle.loadNibNamed("DataView", owner: self, options: nil), let contentView = viewsToAdd.first as? UIView {
            addSubview(contentView)
            contentView.frame = self.bounds
        }
    }
}
