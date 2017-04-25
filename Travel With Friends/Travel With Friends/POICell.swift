//
//  POICell.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/25/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit



protocol POIVoteDelegate : class {
    func sortPOI()
}

class POICell: UITableViewCell {

    @IBOutlet weak var poiNameLabel: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var downVoteButton: UIButton!
    
    var poi : POI! {
        didSet {
            configureCell()
        }
    }
    
    weak var delegate: POIVoteDelegate?


    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell() {
        
        //if user has voted, disable vote button
        if poi.voteFor {
            upVoteButton.isEnabled = false
            downVoteButton.isEnabled = true
        }else{
            upVoteButton.isEnabled = true
            downVoteButton.isEnabled = false
        }
        
        poiNameLabel.text = poi.name
        voteCountLabel.text = "\(poi.voteCount)"
        
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func upVotePressed(_ sender: UIButton) {
        
        poi.voteCount += 1
        
        poi.voteFor = true
        voteCountLabel.text = "\(poi.voteCount)"
        
            upVoteButton.isEnabled = false
            downVoteButton.isEnabled = true
        
        delegate?.sortPOI()
        
    }
    
    @IBAction func downVotePressed(_ sender: UIButton) {
        
        poi.voteCount -= 1
        poi.voteFor = false
        voteCountLabel.text = "\(poi.voteCount)"
        
        
            upVoteButton.isEnabled = true
            downVoteButton.isEnabled = false
        
        delegate?.sortPOI()
        
    }
    
}
