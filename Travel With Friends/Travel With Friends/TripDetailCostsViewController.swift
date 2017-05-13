//
//  TripDetailCostsViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/23/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import FontAwesome_swift
import ParseUI
import UIKit

class TripDetailCostsViewController: PFQueryTableViewController {

    @IBOutlet weak var homeBarButtonItem: UIBarButtonItem!

    let totalCostButton = UIBarButtonItem()
    let totalCostLabel = UILabel()

    var trip: PFObject!

    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "Plan"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "Plan"
    }

    override func queryForTable() -> PFQuery<PFObject> {
        let tabBarController = self.tabBarController as! TripTabBarController
        trip = tabBarController.trip

        let destinationQuery = PFQuery(className: "Destination")
        destinationQuery.whereKey("trip", equalTo: trip)
        destinationQuery.findObjectsInBackground()

        let planQuery = PFQuery(className: parseClassName!)
        planQuery.whereKey("destination", matchesQuery: destinationQuery)

        if let user = PFUser.current() {
            planQuery.whereKey("participants", containedIn: [user])
        }

        planQuery.whereKey("planStage", equalTo: "finalized")
        planQuery.includeKey("destination")
        planQuery.order(byAscending: "startDate")
        return planQuery
    }

    override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)

        var costPerParticipant: Double = 0
        var numberOfParticipants: Double = 0
        var totalCost: Double = 0

        if let objects = objects {
            for object in objects {
                if let participants = object["participants"] as? PFRelation {
                    let relationQuery = participants.query()
                    relationQuery.countObjectsInBackground(block: { (count, error) in
                        numberOfParticipants = Double(count)

                        if let planCost = object["cost"] as? Double {
                            costPerParticipant = planCost / numberOfParticipants
                            totalCost += costPerParticipant
                        }

                        self.totalCostLabel.text = "Total Cost: \((totalCost).asFormattedCurrency())"
                        self.totalCostLabel.sizeToFit()
                    })
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CostCell") as! CostCell

        if let object = object {
            cell.plan = object
        }

        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Trip Costs"

        let nib = UINib(nibName: "CostCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CostCell")

        navigationController?.setToolbarHidden(false, animated: false)
        totalCostButton.customView = totalCostLabel
        totalCostLabel.font = UIFont.Subheadings.TripComposeUserTitleText
        totalCostLabel.tintColor = UIColor.FlatColor.Blue.MainText
        toolbarItems = [totalCostButton]
        
        
        if let font = UIFont(name: "FontAwesome", size: 19) {
            homeBarButtonItem.setTitleTextAttributes(
                [NSFontAttributeName: font], for: .normal)
            homeBarButtonItem.title = String.Fontawesome.Home
           
        }
        
        tableView.backgroundColor = UIColor.FlatColor.White.Background
    }

    @IBAction func showHome(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
