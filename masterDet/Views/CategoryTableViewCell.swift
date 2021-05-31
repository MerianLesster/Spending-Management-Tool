//
//  CategoryTableViewCell.swift
//  masterDet
//
//  Created by Merian Lesster on 15/05/2020.
//  Copyright © 2020 Merian Lesster. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLbl: UILabel!
    @IBOutlet weak var budgetLbl: UILabel!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var categoryContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
