//
//  LoginViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/24/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import SceneKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var globeView: SCNView!
    @IBOutlet weak var loginButton: UIButton!
    
    
    let scene = SCNScene()
    let node = SCNNode()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.globeView.alpha = 0.0
        self.titleLabel.alpha = 0.0
        self.loginButton.alpha = 0.0
        
        globeView.scene = scene
        globeView.autoenablesDefaultLighting = true
        
        node.geometry = SCNSphere(radius: 1)
        node.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "diffuse")
        node.geometry?.firstMaterial?.specular.contents = #imageLiteral(resourceName: "specular")
        node.geometry?.firstMaterial?.normal.contents = #imageLiteral(resourceName: "normal")
        node.geometry?.firstMaterial?.emission.contents = #imageLiteral(resourceName: "emission")
        node.geometry?.firstMaterial?.transparent.contents = #imageLiteral(resourceName: "transparent")
        scene.rootNode.addChildNode(node)
        
        let action = SCNAction.rotate(by: 360 * CGFloat(.pi/180.0), around: SCNVector3(x:0, y:1, z:0), duration: 8)
        
        let repeatAction = SCNAction.repeatForever(action)
        
        node.runAction(repeatAction)
        

 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 2.0) {
            self.globeView.alpha = 1.0
            self.titleLabel.alpha = 1.0
            self.loginButton.alpha = 1.0
        }
        
       
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


