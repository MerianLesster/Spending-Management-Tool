//
//  ExpenseTableViewCell.swift
//  masterDet
//
//  Created by Merian Lesster on 15/05/2020.
//  Copyright © 2020 Merian Lesster. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var occurenceLbl: UILabel!
    @IBOutlet weak var reminderSetLbl: UILabel!
    @IBOutlet weak var customProgressBar: PlainHorizontalProgressBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
