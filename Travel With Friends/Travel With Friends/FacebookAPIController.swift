//
//  FacebookAPIController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/27/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin



class FacebookAPIController {
    static let shared = FacebookAPIController()
    
    let accessToken = AccessToken.current
    
    
    /// Logs the user out and clears the saved credentials
    func logout() {
        
        let loginManager = LoginManager()
        loginManager.logOut()        
        NotificationCenter.default.post(name: NSNotification.Name("UserDidLogout"), object: nil)
        
    }
    
    
}
