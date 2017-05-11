//
//  ProfileEurekaCell.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 5/9/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse
import Eureka
import AlamofireImage

final class ProfileEurekaCell: Cell<PFUser>, CellType {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1 // as you wish

        
        height = { return 80 }

    }
    
    override func update() {
        super.update()
        
        // we do not want to show the default UITableViewCell's textLabel
        textLabel?.text = nil
        
        // get the value from our row
        guard let user = row.value else { return }
        

        if let imageString = user["fbImageString"] as? String {
            let url = URL(string: imageString)!
            let placeholderImage = UIImage(named: "profile-placeholder")!
            
         
            
            profileImageView.af_setImage(
                withURL: url,
                placeholderImage: placeholderImage,
                filter: nil,
                imageTransition: .crossDissolve(0.5)
            )
        }
        
        
        // set the texts to the labels
        emailLabel.text = user["email"] as? String
        nameLabel.text = user["name"] as? String
    }
    
    
}

final class ProfileEurekaRow: Row<ProfileEurekaCell>, RowType {
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<ProfileEurekaCell>(nibName: "ProfileEurekaCell")
    }
}
