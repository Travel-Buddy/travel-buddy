//
//  PlanTypesViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 5/8/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Parse

class PlanTypesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    weak var delegate: PlanComposerViewControllerDelegate?

    let types = [
        "flight",
        "car_rental",
        "accommodation",
        "restaurant",
        "establishment",
        "non-establishment"
    ]
    let typeNames = [
        "flight" : "Flight",
        "car_rental" : "Car Rental",
        "accommodation" : "Accommodation",
        "restaurant" : "Restaurant",
        "establishment" : "Landmark",
        "non-establishment" : "Other Activity"
    ]

    var trip: PFObject!
    var destination: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.FlatColor.White.Background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self,
                forCellReuseIdentifier: "TableViewCell")
        
        if let font = UIFont(name: "FontAwesome", size: 19) {
            cancelButton.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            cancelButton.title = String.Fontawesome.Cancel

        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposePlanSegue" {
                let viewController = segue.destination
                            as! PlanComposerContainerViewController
                let cell = sender as! UITableViewCell
                
                let indexPath = tableView.indexPath(for: cell)!

                viewController.delegate = delegate
                viewController.trip = trip
                viewController.destination = destination
                viewController.plan = nil
                viewController.planType = types[indexPath.row]
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension PlanTypesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int {
        return types.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: "TableViewCell", for: indexPath)
        cell.backgroundColor = UIColor.FlatColor.White.Background
        cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
        cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
        cell.textLabel?.text = typeNames[types[indexPath.row]]

        return cell
    }

    func tableView(_ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "ComposePlanSegue",
                sender: tableView.cellForRow(at: indexPath))
    }
}
