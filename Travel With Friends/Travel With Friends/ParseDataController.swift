//
//  ParseDataController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/27/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation
import Parse


class ParseDataController {
    static let shared = ParseDataController()
    
    /// Logs the user out and clears the saved credentials
    func logout() {
        
        PFUser.logOut()
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
        
    }
    
    
}
