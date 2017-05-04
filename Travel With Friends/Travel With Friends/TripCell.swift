//
//  TripCell.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse

class TripCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var destinationsLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    
    
    var trip : PFObject! {
        didSet {
            configureCell()
        }
    }
    
    
    func configureCell(){
        
    }
    

    @IBAction func editTrip(_ sender: Any) {
        
    }
    
}
