//
//  PlanCell.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import ParseUI

class PlanCell: PFTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!

    var plan: PFObject! {
        didSet {
            updateCell()
        }
    }

    func updateCell() {
        nameLabel.text = plan["estabName"] as? String
        locationLabel.text = plan["estabLocation"] as? String
    }

    @IBAction func deletePlan(_ sender: Any) {
        /* TODO: Implement deleting a plan functionality */
    }
}
