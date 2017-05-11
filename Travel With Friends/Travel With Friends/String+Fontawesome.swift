//
//  String+Fontawesome.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 5/9/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation


extension String {
    
    /* Use 'fa-home' and 'fa-plus' text icon from FontAwesome.
     * http://fontawesome.io/cheatsheet/
     * NOTE: Intentionally set the two with different size because 'fa-home'
     *       looks slightly smaller than 'fa-plus'.
     */
    struct Fontawesome {
        static let Trips = "\u{f0f2}"
        static let Profile = "\u{f007}"
        static let Add = "\u{f067}"
        static let Save = "\u{f0c7}"
        static let Cancel = "\u{f05e}"
        static let CancelX = "\u{f00d}"
        static let AddCircle = "\u{f055}"
        static let Home = "\u{f015}"
        
    }
    
}
