//
//  PlanCell.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Parse

class PlanCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!

    var plan: PFObject! {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        nameLabel.text = plan["estabName"] as? String

        if let location = plan["estabLocation"] as? String {
            locationLabel.text = location
        } else if let location = plan["startLocation"] as? String {
            locationLabel.text = location
        }

        let relation = plan.relation(forKey: "likedBy")
        relation.query().findObjectsInBackground {
                (users: [PFObject]?, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else if let users = users {
                        var isLikedByUser = false
                        for user in users {
                            if user.objectId == PFUser.current()!.objectId {
                                isLikedByUser = true
                                break
                            }
                        }
                        self.likeButton.setTitleColor(
                                (isLikedByUser ? .red : .lightGray),
                                for: .normal)
                        self.likeCountLabel.text = "\(users.count)"
                    }
                }
    }

    func updateIsLikedByUser(_ isLikedByUser: Bool) {
        let relation = plan.relation(forKey: "likedBy")
        if isLikedByUser {
            relation.add(PFUser.current()!)
        } else {
            relation.remove(PFUser.current()!)
        }
        plan.saveInBackground {
                (success: Bool, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else if success {
                        self.updateUI()
                    }
                }
    }

    @IBAction func toggleIsLikedByUser(_ sender: Any) {
        let relation = plan.relation(forKey: "likedBy")
        relation.query().findObjectsInBackground {
                (users: [PFObject]?, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else if let users = users {
                        var isLikedByUser = false
                        for user in users {
                            if user.objectId == PFUser.current()!.objectId {
                                isLikedByUser = true
                                break
                            }
                        }
                        self.updateIsLikedByUser(!isLikedByUser)
                    }
                }
    }
}
