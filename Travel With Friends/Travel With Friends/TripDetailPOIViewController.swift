//
//  TripDetailPOIViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/23/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

class TripDetailPOIViewController: UIViewController {

    @IBOutlet weak var poiTableView: UITableView!
    
    
    
    var poiArray : [POI] = [POI(n: "new yrk"),POI(n: "big apple"),POI(n: "hello world"),POI(n: "temp 3"),POI(n: "4 temp"),POI(n: "temp"),POI(n: "temp"),POI(n: "temp"),POI(n: "temp")]
    
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "POICell") as! POICell
        
        cell.poi = poiArray[indexPath.row]
        cell.delegate = self
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return poiArray.count
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

class POI {
    var name : String = ""
    var voteCount: Int = 0
    var voteFor = false
    
    
    init(n: String) {
        name = n
    }
    
    //need to change to dictionary of users that have voted
    // var voted = [UserID : true] etc
    
}







