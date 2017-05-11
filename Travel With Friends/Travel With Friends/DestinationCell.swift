//
//  DestinationCell.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import ParseUI
import UIKit

class DestinationCell: PFTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!

    var destination: PFObject! {
        didSet {
            titleLabel.text = destination["title"] as? String
            subtitleLabel.text = destination["subtitle"] as? String

            if let startDate = destination["startDate"] as? Date, let endDate = destination["endDate"] as? Date {
                if endDate.compare(startDate) == .orderedSame {
                    dateRangeLabel.text = startDate.asString()
                } else {
                    dateRangeLabel.text = startDate.asString() + " - " + endDate.asString()
                }
            }
        }
    }

}
