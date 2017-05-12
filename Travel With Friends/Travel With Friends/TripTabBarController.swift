//
//  TripTabBarController.swift
//  Travel With Friends
//
//  Created by Curtis Wilcox on 5/10/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import FontAwesome_swift
import Parse
import UIKit

class TripTabBarController: UITabBarController {

    var trip = PFObject(className: "Trip")

    override func viewDidLoad() {
        super.viewDidLoad()

        if let destinationsTabItem = tabBar.items?[0] {
            destinationsTabItem.image = UIImage.fontAwesomeIcon(name: .globe, textColor: UIColor.FlatColor.Blue.MainText, size: CGSize(width: 30, height: 30))
        }

        if let costsTabItem = tabBar.items?[1] {
            costsTabItem.image = UIImage.fontAwesomeIcon(name: .dollar, textColor: UIColor.FlatColor.Blue.MainText, size: CGSize(width: 30, height: 30))
        }
        
        self.tabBar.tintColor = UIColor.FlatColor.Blue.MainText
        
    }

}
