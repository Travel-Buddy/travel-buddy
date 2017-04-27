//
//  TripTableViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/23/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

class TripTableViewController: UIViewController {
    
    @IBOutlet weak var tripTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tripTableView.delegate = self
        tripTableView.dataSource = self
        


        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        FacebookAPIController.shared.logout()
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


extension TripTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TripCell")!
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
        
    }
}


