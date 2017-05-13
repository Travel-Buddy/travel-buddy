//
//  DetailedPlanViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Parse

@objc protocol DetailedPlanViewControllerDelegate {
    @objc optional func detailedPlanViewController(
            _ detailedPlanViewController: DetailedPlanViewController,
            didEditPlan plan: PFObject)
}

class DetailedPlanViewController: UIViewController {
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var establishmentNameLabel: UILabel!
    @IBOutlet weak var establishmentLocationLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var finalizePlanButton: UIButton!

    weak var delegate: DetailedPlanViewControllerDelegate?

    var destination: PFObject!
    var plan: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let font = UIFont(name: "FontAwesome", size: 19) {
            editBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            editBarButtonItem.title = String.Fontawesome.Edit
        }

        finalizePlanButton.contentEdgeInsets = UIEdgeInsets(
                top: 5, left: 20, bottom: 5, right: 20)
        finalizePlanButton.layer.cornerRadius = 4
        finalizePlanButton.clipsToBounds = true

        updateUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /* NOTE: In detailed view, we don't want to have anything at the bottom
         *       so hide the tab bar if this VC is within UITabBarController
         */
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        /* NOTE: Put the tab bar back if this VC is within UITabBarController */
        tabBarController?.tabBar.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposePlanSegue" {
                var viewController: PlanComposerContainerViewController
                
                if let navigationController = segue.destination
                           as? UINavigationController {
                    /* Must do this because PlanComposerContainerViewController
                     * is not the topViewController of the NavigationController
                     */
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    viewController = storyboard.instantiateViewController(
                            withIdentifier: "PlanComposerContainerViewController")
                            as! PlanComposerContainerViewController
                    navigationController.pushViewController(viewController,
                            animated: true)
                } else {
                    viewController = segue.destination
                            as! PlanComposerContainerViewController
                }
                viewController.delegate = self
                viewController.destination = destination
                viewController.plan = plan
            }
        }
    }

    func updateUI() {
        if let establishmentName = plan["estabName"] as? String {
            establishmentNameLabel.text = establishmentName
        }

        if let establishmentLocation = plan["estabLocation"] as? String {
            establishmentLocationLabel.text = establishmentLocation
        }

        if let startDate = plan["startDate"] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy")
            startDateLabel.text = dateFormatter.string(from: startDate)
        }

        if let planStage = plan["planStage"] as? String {
            if planStage == "proposal" {
                finalizePlanButton.setTitle("Finalize Plan", for: .normal)
            } else if planStage == "finalized" {
                finalizePlanButton.setTitle("Reconsider Plan", for: .normal)
            }
        }

        if let createdByUser = plan["createdBy"] as? PFObject {
            createdByUser.fetchIfNeededInBackground {
                    (user: PFObject?, error: Error?) in
                        if let name = user?["name"] as? String {
                            self.createdByLabel.text = name
                        }
                    }
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
                        self.delegate?.detailedPlanViewController?(
                                self, didEditPlan: self.plan)
                    }
                }
    }

    @IBAction func editPlan(_ sender: Any) {
        performSegue(withIdentifier: "ComposePlanSegue", sender: nil)
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

    @IBAction func updatePlanStage(_ sender: Any) {
        if let stage = plan["planStage"] as? String {
            if stage == "proposal" {
                plan["planStage"] = "finalized"
            } else if stage == "finalized" {
                plan["planStage"] = "proposal"
            }
            plan.saveInBackground {
                    (success: Bool, error: Error?) in
                        if let error = error {
                            print("ERROR: \(error.localizedDescription)")
                        } else if success {
                            self.updateUI()
                            self.delegate?.detailedPlanViewController?(
                                    self, didEditPlan: self.plan)
                        }
                    }
        }
    }
}

extension DetailedPlanViewController: PlanComposerViewControllerDelegate {
    func planComposerViewController(
            _ planComposerViewController: PlanComposerViewController,
            didSavePlan plan: PFObject) {
        self.plan = plan
        updateUI()
        self.delegate?.detailedPlanViewController?(self, didEditPlan: plan)
    }
}
