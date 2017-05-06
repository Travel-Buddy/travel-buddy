//
//  TripCell.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse
import ParseUI


protocol TripCellDelegate : class {
    func edit(trip: PFObject)

}

class TripCell: PFTableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateRangeLabel: UILabel!
    @IBOutlet weak var participantsLabel: UILabel!
    
    @IBOutlet weak var ownerLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    
    var trip : PFObject! {
        didSet {
            configureCell()
        }
    }
    
    
    func configureCell(){
        nameLabel.text = trip["title"] as? String
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let startDate = trip["startDate"] as? Date
        let endDate = trip["endDate"] as? Date
        
        if let startDate = startDate, let endDate = endDate {
            dateRangeLabel.text = "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        }else{
            dateRangeLabel.text = ""
        }
        
        
        let owner = trip["createdBy"] as? PFUser
        let current = PFUser.current()
        
        
        if let owner = owner, let current = current, owner["facebookId"] as! String == current["facebookId"] as! String {
            ownerLabel.text = "From You"

        }else if let owner = owner{
            ownerLabel.text = "From \(owner["name"]!)"
        }
        
        
    }
    


    
}
