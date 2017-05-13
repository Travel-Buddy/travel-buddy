//
//  FlightPlanCell.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 5/12/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Parse

class FlightPlanCell: UITableViewCell {
    @IBOutlet weak var locationsLabel: UILabel!
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var airlineNameLabel: UILabel!
    @IBOutlet weak var flightNoLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!

    var plan: PFObject! {
        didSet {
            updateUI()
        }
    }

    func updateUI() {
        if let startLocation = plan["startLocation"] as? String,
           let endLocation = plan["endLocation"] as? String {
            locationsLabel.text = startLocation + " - " + endLocation
        }

        if let startDate = plan["startDate"] as? Date,
           let endDate = plan["endDate"] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy hh:mm a"
            datesLabel.text = dateFormatter.string(from: startDate) + " - " +
                    dateFormatter.string(from: endDate)
        }

        airlineNameLabel.text = plan["estabName"] as? String
        flightNoLabel.text = plan["estabNbr"] as? String

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
