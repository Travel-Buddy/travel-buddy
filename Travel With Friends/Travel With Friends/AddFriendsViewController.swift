//
//  AddFriendsViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 5/5/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol AddFriendsDelegate : class {
    func add(friendsToAdd: [PFObject])
}

class AddFriendsViewController: PFQueryTableViewController {

    
    var friends : [PFObject] = []
    weak var delegate : AddFriendsDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func add(_ sender: Any) {
        
        
        self.delegate?.add(friendsToAdd: friends)
        
        dismiss(animated: true)
    }
    
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 20
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 20
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFUser.query()!
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        if self.objects!.count == 0 {
            query.cachePolicy = .cacheThenNetwork
        }
        
        query.whereKey("facebookId", notEqualTo: PFUser.current()!["facebookId"])
        
        query.order(byDescending: "createdAt")
        
        return query
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cellIdentifier = "cell"
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? PFTableViewCell
        if cell == nil {
            cell = PFTableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        // Configure the cell to show todo item with a priority at the bottom
        if let object = object {
            cell!.textLabel?.text = object["name"] as? String
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            
            
            if let index = friends.index(of: self.objects![indexPath.row]) {
                friends.remove(at: index)
            }
            
            
           // friends.removeValue(forKey: self.objects![indexPath.row]["facebookId"] as! String)
        }else {
            cell.accessoryType = .checkmark
            friends.append(self.objects![indexPath.row])
            
        }
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
