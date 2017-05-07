//
//  TripsViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse

class TripsViewController: UIViewController {
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tripsTableView: UITableView!

    var testTripNames = [
        "2018 Winter Olympics",
        "2017 Total Solar Eclipse",
        "2017 Greece",
        "2016 Xmas - New Year",
        "2016 Chicago",
        "2016 Summer Olympics",
        "2016 East Asia"
    ]
    var testTripDateRanges = [
        "February 14, 2018 - February 25, 2018",
        "August 18, 2017 - August 22, 2017",
        "July 23, 2017 - July 30, 2017",
        "December 25, 2016 - January 1, 2017",
        "September 29, 2016 - October 2, 2016",
        "August 10, 2016 - August 29, 2016",
        "March 22, 2016 - April 10, 2016"
    ]
    var testTripDestinations = [
        "Seoul, PyeongChang",
        "Salt Lake City, Yellowstone National Park, Grand Teton National Park",
        "Athens, Santorini, Meteora, Crete",
        "Seattle, Whistler, Vancouver",
        "Chicago",
        "Iguazu, Rio de Janeiro, Amazon Rainforest",
        "Kyoto, Osaka, Matsusaka, Tokyo, Seoul"
    ]
    var testTripParticipants = [
        "Janvier Wijaya, Minxi Rao",
        "Janvier Wijaya, Minxi Rao, Gautam Srinivasan, Jeffrey Chen",
        "Janvier Wijaya, Minxi Rao, Sutanto Wibowo, Agatha Christy",
        "Janvier Wijaya, Minxi Rao, Vincent Duong, Debbie Leung",
        "Janvier Wijaya, Minxi Rao",
        "Janvier Wijaya, Gautam Srinivasan, Joe Lin",
        "Janvier Wijaya, Andrew Tran, Lisa Chang"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Use 'fa-plus' icon from FontAwesome.
         * http://fontawesome.io/cheatsheet/
         */
        if let font = UIFont(name: "FontAwesome", size: 17) {
            addBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            addBarButtonItem.title = "\u{f067}"
        }

        tripsTableView.dataSource = self
        tripsTableView.delegate = self
        tripsTableView.rowHeight = UITableViewAutomaticDimension
        tripsTableView.estimatedRowHeight = 118

        let nib = UINib(nibName: "TripCell", bundle: nil)
        tripsTableView.register(nib, forCellReuseIdentifier: "TripCell")
        
        
        let query = PFQuery(className:"Trip")
        query.whereKey("users", equalTo: PFUser.current()!)
        
        query.findObjectsInBackground { (trips, error) in
            if let trips = trips {
                
                for trip in trips {
                    let relation = trip.relation(forKey: "users")
                    let queryUsers = relation.query()
                    queryUsers.findObjectsInBackground(block: { (users, error) in
                        if let users = users {
                            print(users)
                        }
                    })
                    
                }
                
                
            }
        }
        
        
        
        
    }

    @IBAction func logout(_ sender: UIBarButtonItem) {
        ParseDataController.shared.logout()
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposeTripSegue" {
                /* TODO: Implement creating a new trip functionality in
                 *       TripComposerViewController
                 */
            } else if identifier == "ShowTripDetailSegue" {
                if let tabBarController = segue.destination as? UITabBarController {
                  tabBarController.selectedIndex = 0
                }
            }
        }
    }

    @IBAction func createTrip(_ sender: Any) {
        performSegue(withIdentifier: "ComposeTripSegue", sender: nil)
    }
}

extension TripsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int {
        return testTripNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell",
                for: indexPath) as! TripCell

        cell.nameLabel.text = testTripNames[indexPath.row]
        cell.dateRangeLabel.text = testTripDateRanges[indexPath.row]
//        cell.destinationsLabel.text = testTripDestinations[indexPath.row]
//        cell.participantsLabel.text = testTripParticipants[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "ShowTripDetailSegue",
                sender: tableView.cellForRow(at: indexPath))
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        //if user is owner, return true, else return false
    
        return false
        
    }
    
    
    // this method handles row deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            
            // remove the item from the data model
           // animals.remove(at: indexPath.row)
            testTripNames.remove(at: indexPath.row)
            testTripDateRanges.remove(at: indexPath.row)
            testTripDestinations.remove(at: indexPath.row)
            testTripParticipants.remove(at: indexPath.row)
            
            // delete the table view row
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
            
        
    }
    
    
}
