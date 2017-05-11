//
//  CostCell.swift
//  Travel With Friends
//
//  Created by Curtis Wilcox on 5/6/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import ParseUI
import UIKit

class CostCell: PFTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!

    var plan: PFObject! {
        didSet {
            titleLabel.text = plan["estabName"] as? String
            subtitleLabel.text = plan["destination"] as? String

            if let startDate = plan["startDate"] as? Date, let endDate = plan["endDate"] as? Date {
                if endDate.compare(startDate) == .orderedSame {
                    dateRangeLabel.text = startDate.asString()
                } else {
                    dateRangeLabel.text = startDate.asString() + " - " + endDate.asString()
                }
            }

            if let cost = plan["cost"] as? NSNumber {
                costLabel.text = cost.asFormattedCurrency()
            }
        }
    }

}
