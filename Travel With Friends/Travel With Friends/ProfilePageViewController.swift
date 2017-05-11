//
//  ProfilePageViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 5/9/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Eureka
import Parse
import FBSDKCoreKit
import FBSDKShareKit

class ProfilePageViewController: FormViewController {
    @IBOutlet weak var closeButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let font = UIFont(name: "FontAwesome", size: 19) {
            closeButton.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            closeButton.title = String.Fontawesome.Trips
        }
        
        self.navigationItem.title = "Profile Page"
        
        form +++
            Section("")
            <<< ProfileEurekaRow { row in
                row.value = PFUser.current()!
            }
            +++ Section("")
            <<< ButtonRow() { (row: ButtonRow) in
                row.title = "Invite Friends"
                row.cell.backgroundColor = UIColor.FlatColor.White.Background
                row.cell.tintColor = UIColor.FlatColor.Green.Subtext
                row.cell.textLabel?.font = UIFont.Buttons.ProfilePageButton
                
                }
                .onCellSelection({ (cell, row) in
                    self.inviteFriends()
                })
            // +++ Section("")
            <<< ButtonRow() { (row: ButtonRow) in
                row.title = "Logout"
                row.cell.backgroundColor = UIColor.FlatColor.White.Background
                row.cell.tintColor = UIColor.FlatColor.Green.Subtext
                row.cell.textLabel?.font = UIFont.Buttons.ProfilePageButton
                
                }
                .onCellSelection({ (cell, row) in
                    ParseDataController.shared.logout()
                })
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func closeProfilePage(_ sender: Any) {
        self.dismiss(animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func inviteFriends() {
        let inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
        if(inviteDialog.canShow()){
            let appLinkUrl:NSURL = NSURL(string: "http://yourwebpage.com")!
            let previewImageUrl:NSURL = NSURL(string: "http://yourwebpage.com/preview-image.png")!
            
            let inviteContent:FBSDKAppInviteContent = FBSDKAppInviteContent()
            inviteContent.appLinkURL = appLinkUrl as URL!
            inviteContent.appInvitePreviewImageURL = previewImageUrl as URL!
            
            inviteDialog.content = inviteContent
            inviteDialog.delegate = self
            inviteDialog.show()
        }    }
    
}

extension ProfilePageViewController : FBSDKAppInviteDialogDelegate {
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
//        if let didCancel = results["completionGesture"]
//        {
//            if (didCancel as AnyObject).caseInsensitiveCompare("Cancel") == ComparisonResult.orderedSame
//            {
//                print("User Canceled invitation dialog")
//            }
//        }
    
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("Error took place in appInviteDialog \(error)")
    }
    
    
    
}
