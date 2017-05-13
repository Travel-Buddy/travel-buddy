//
//  DestinationsViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import FontAwesome_swift
import ParseUI
import UIKit

class DestinationsViewController: PFQueryTableViewController {

    @IBOutlet weak var homeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!

    var trip: PFObject!

    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "Destination"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "Destination"
    }

    override func queryForTable() -> PFQuery<PFObject> {
        let tabBarController = self.tabBarController as! TripTabBarController
        trip = tabBarController.trip
        
        let destinationQuery = PFQuery(className: parseClassName!)
        destinationQuery.whereKey("trip", equalTo: trip)
        destinationQuery.order(byAscending: "startDate")
        return destinationQuery
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DestinationCell") as! DestinationCell

        if let object = object {
            cell.destination = object
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowDestinationDetailSegue", sender: tableView.cellForRow(at: indexPath))
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let destination = self.object(at: indexPath) {
                let planQuery = PFQuery(className: "Plan")
                planQuery.whereKey("destination", equalTo: destination.objectId!)
                planQuery.findObjectsInBackground(block: { (plans, error) in
                    if let error = error {
                        self.displayAlert(message: error.localizedDescription)
                    } else {
                        if let plans = plans {
                            for plan in plans {
                                plan.deleteInBackground(block: { (success, error) in
                                    if let error = error {
                                        self.displayAlert(message: error.localizedDescription)
                                    }
                                })
                            }
                        }
                    }

                    destination.deleteInBackground(block: { (success, error) in
                        if success {
                            self.loadObjects()
                            self.tableView.reloadData()
                        } else if let error = error {
                            self.displayAlert(message: error.localizedDescription)
                        }
                    })
                })
            }
        }
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        performSegue(withIdentifier: "EditDestinationSegue", sender: tableView.cellForRow(at: indexPath))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableView), name: NSNotification.Name(rawValue: "loadDestinations"), object: nil)

        
        
        if let font = UIFont(name: "FontAwesome", size: 19) {
            homeBarButtonItem.setTitleTextAttributes(
                [NSFontAttributeName: font], for: .normal)
            homeBarButtonItem.title = String.Fontawesome.Home
            addBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            addBarButtonItem.title = String.Fontawesome.Add
        }
        
        tableView.backgroundColor = UIColor.FlatColor.White.Background

        let nib = UINib(nibName: "DestinationCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "DestinationCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposeDestinationSegue" {
                let navVc = segue.destination as? UINavigationController
                let vc = navVc?.viewControllers.first as! DestinationComposerViewController
                vc.trip = trip!
                vc.navigationItem.title = "Create Destination"
            } else {
                let cell = sender as! PFTableViewCell
                let indexPath = tableView.indexPath(for: cell)
                let destination = object(at: indexPath)

                if identifier == "EditDestinationSegue" {
                    let navVc = segue.destination as? UINavigationController
                    let vc = navVc?.viewControllers.first as! DestinationComposerViewController
                    vc.trip = trip!
                    vc.destination = destination
                    vc.isEditingDestination = true
                    vc.navigationItem.title = "Edit Destination"
                }

                if identifier == "ShowDestinationDetailSegue" {
                    let vc = segue.destination as! PlansViewController
                    vc.trip = trip
                    vc.destination = destination
                }
            }
        }
    }

    @IBAction func showHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func createDestination(_ sender: Any) {
        performSegue(withIdentifier: "ComposeDestinationSegue", sender: nil)
    }

    func displayAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }

    func reloadTableView() {
        loadObjects()
        tableView.reloadData()
    }

}
