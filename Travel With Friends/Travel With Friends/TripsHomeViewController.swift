//
//  TripsHomeViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 5/4/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class TripsHomeViewController: PFQueryTableViewController {

    @IBOutlet weak var addTripBarButton: UIBarButtonItem!
    var tripToEdit : PFObject?
    var shouldReload = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let font = UIFont(name: "FontAwesome", size: 17) {
            addTripBarButton.setTitleTextAttributes(
                [NSFontAttributeName: font], for: .normal)
            addTripBarButton.title = "\u{f067}"
        }
        
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 118
        
        let nib = UINib(nibName: "TripCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TripCell")
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldReload {
            self.loadObjects()
            shouldReload = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        ParseDataController.shared.logout()
    }
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "Trip"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "Trip"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: self.parseClassName!)
        
       // query.whereKey("users", equalTo: PFUser.current()!)
        query.includeKey("createdBy")
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        if self.objects!.count == 0 {
            query.cachePolicy = .cacheThenNetwork
        }
        
        query.order(byAscending: "startDate")
                
        return query

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell",
                                                 for: indexPath) as! TripCell
        cell.trip = object
        return cell

    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let object = objects![indexPath.row]
        
        let owner = object["createdBy"] as? PFUser
        let current = PFUser.current()
        
        
        if let owner = owner, let current = current, owner["facebookId"] as! String == current["facebookId"] as! String {
            return true
        }
        
        return false
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            self.removeObject(at: indexPath, animated: true)
            
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tripToEdit = objects![indexPath.row]
        self.performSegue(withIdentifier: "ComposeTripSegue", sender: self)
    }
    
    
    @IBAction func addTrip(_ sender: Any) {
        self.performSegue(withIdentifier: "ComposeTripSegue", sender: self)
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "ComposeTripSegue" {
                
                let composeNavVC = segue.destination as! UINavigationController
                
                let composeVC = composeNavVC.viewControllers[0] as! TripComposerViewController
                
                if tripToEdit != nil {
                    composeVC.tripToEdit = tripToEdit
                    tripToEdit = nil
                }
                shouldReload = true

                
            } else if segue.identifier == "ShowTripDetailSegue" {
                if let tabBarController = segue.destination as? UITabBarController {
                    tabBarController.selectedIndex = 0
                }
            }
    }
 

}


