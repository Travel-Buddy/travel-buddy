//
//  TripDetailPOIViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/23/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Alamofire
import UnboxedAlamofire

class TripDetailPOIViewController: UIViewController {
    
    @IBOutlet weak var poiTableView: UITableView!
    
    
    
    var poiArray : [GooglePlacePOI] = []
    var fbUserArray : [FacebookUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        poiTableView.delegate = self
        poiTableView.dataSource = self
        
        poiTableView.estimatedRowHeight = 90
        
        poiArray.sort {
            $0.voteCount == $1.voteCount ? ($0.name < $1.name) : ($0.voteCount > $1.voteCount)
        }
        
        
        //load xib file
        let nib = UINib(nibName: "POICell", bundle: nil)
        poiTableView.register(nib, forCellReuseIdentifier: "POICell")
        
        let fbNib = UINib(nibName: "FacebookUserCell", bundle: nil)
        poiTableView.register(fbNib, forCellReuseIdentifier: "FacebookCell")
        
        
//        GooglePlacesAPIController.shared.getPOIFrom(locationString: "New York City") { (places, error) in
//            if let places = places {
//                self.poiArray = places
//                self.poiTableView.reloadData()
//            }else{
//                print("Handle Error")
//            }
//        }
        
        FacebookAPIController.shared.getUsersFriendsWhoHaveApp { (users, error) in
            if let users = users {
                self.fbUserArray = users
                self.poiTableView.reloadData()
            }else{
                print("Handle Error")
            }

        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true)
        
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

extension TripDetailPOIViewController : UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell") as! POICell
//        
//        cell.poi = poiArray[indexPath.row]
//        cell.delegate = self
//        return cell
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FacebookCell") as! FacebookUserCell
        
        cell.user = fbUserArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return poiArray.count
        return fbUserArray.count
    }
    
}

extension TripDetailPOIViewController : POIVoteDelegate {
    func sortPOI() {
        poiArray.sort {
            $0.voteCount == $1.voteCount ? ($0.name < $1.name) : ($0.voteCount > $1.voteCount)
        }
        poiTableView.reloadData()
        
    }
}






