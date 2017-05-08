//
//  LoginViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/24/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

 
    }

    @IBAction func loginViaFB(_ sender: UIButton) {
        
        PFFacebookUtils.logInInBackground(withReadPermissions: ["public_profile", "email", "user_friends"]) { (user, error) in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
                
                ParseDataController.shared.updateUserFields()
                self.performSegue(withIdentifier: "LoginSegue", sender: nil)
                
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


