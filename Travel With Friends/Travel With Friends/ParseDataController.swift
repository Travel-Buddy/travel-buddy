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
    
    func updateUserFacebookFrinds() {
        
        let user = PFUser.current()
        
        if let user = user {
            
            FacebookAPIController.shared.getUsersFriendsWhoHaveApp(completion: { (fbusers, error) in
                if let fbusers = fbusers {
                    
                    var fbIdArray : [Any] = []
                    
                    for fbuser in fbusers {
                        fbIdArray.append("\(fbuser.id)" as Any)
                    }
                    
                    let query = PFUser.query()!
                    
                    query.whereKey("facebookId", containedIn: fbIdArray)
                    
                    query.order(byDescending: "createdAt")
                    
                    
                    query.findObjectsInBackground(block: { (objects, error) in
                        if let objects = objects {
                            
                            for object in objects {
                                let relation = user.relation(forKey: "facebookFriends")
                                relation.add(object)
                                
                                user.saveInBackground(block: { (success, error) in
                                    print(success)
                                })
                                
                                
                            }
                        }
                    })
                    
                    
                }
            })
            
            
            
        }
        
        
    }
    
    
    //updated the fields of the current user in the parse db on new user creation
    func updateUserFields(){
        
        let user = PFUser.current()
        
        if let user = user {
            FacebookAPIController.shared.getUserInfo(completion: { (fbUser, error) in
                if let fbUser = fbUser {
                    user["email"] = fbUser.email
                    user["name"] = fbUser.name
                    user["facebookId"] = "\(fbUser.id)"
                    
                    if let pictureString = fbUser.picture?.pictureData?.url?.absoluteString {
                        user["fbImageString"] = pictureString
                    }                    
                    user.saveInBackground(block: { (success, error) in
                        if success {
                            print(success)
                            print("saved user")
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            })
        }
    }
    
    
}
