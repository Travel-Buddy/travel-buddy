//
//  LoginViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/24/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import FacebookLogin

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email, .userFriends ])
        loginButton.center = view.center
        
        view.addSubview(loginButton)
        
        // Do any additional setup after loading the view.
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
