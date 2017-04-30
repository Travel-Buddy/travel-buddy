//
//  FacebookUserCell.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/28/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import AlamofireImage

class FacebookUserCell: UITableViewCell {

    @IBOutlet weak var facebookUserProfileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var user : FacebookUser! {
        didSet {
            configureCell()
        }
    }
    
    func configureCell() {
        nameLabel.text = user.name
        //need to update to be safer
        facebookUserProfileImageView.af_setImage(withURL: (user.picture?.pictureData?.url!)!)
        
        
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
