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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let font = UIFont(name: "FontAwesome", size: 17) {
            addTripBarButton.setTitleTextAttributes(
                [NSFontAttributeName: font], for: .normal)
            addTripBarButton.title = "\u{f067}"
        }
        
        // Do any additional setup after loading the view.
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
        objectsPerPage = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "Trip"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 1
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: self.parseClassName!)
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        if self.objects!.count == 0 {
            query.cachePolicy = .cacheThenNetwork
        }
        
        query.order(byDescending: "createdAt")
        
        return query

    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellIdentifier = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PFTableViewCell
        if cell == nil {
            cell = PFTableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        if let object = object {
            cell!.textLabel?.text = object["title"] as? String
           
        }
        
        return cell

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
