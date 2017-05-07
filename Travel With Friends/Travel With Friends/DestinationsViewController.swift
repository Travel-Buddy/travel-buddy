//
//  DestinationsViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import Parse

class DestinationsViewController: UIViewController {
    @IBOutlet weak var destinationsTableView: UITableView!
    @IBOutlet weak var homeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!

    /* DEBUG CODE BEG */
    let testDestinationNames = [
        "Salt Lake City",
        "Yellowstone National Park",
        "Grand Teton National Park",
        "Salt Lake City"
    ]
    let testDateRanges = [
        "August 18, 2017",
        "August 19, 2017 - August 20, 2017",
        "August 21, 2017",
        "August 22, 2017"
    ]

    var destination: PFObject?
    /* DEBUG CODE END */

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Use 'fa-home' and 'fa-plus' text icon from FontAwesome.
         * http://fontawesome.io/cheatsheet/
         * NOTE: Intentionally set the two with different size because 'fa-home'
         *       looks slightly smaller than 'fa-plus'.
         */
        if let font = UIFont(name: "FontAwesome", size: 19) {
            homeBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            homeBarButtonItem.title = "\u{f015}"
        }
        if let font = UIFont(name: "FontAwesome", size: 17) {
            addBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            addBarButtonItem.title = "\u{f067}"
        }

        destinationsTableView.dataSource = self
        destinationsTableView.delegate = self
        destinationsTableView.rowHeight = UITableViewAutomaticDimension
        destinationsTableView.estimatedRowHeight = 67

        let nib = UINib(nibName: "DestinationCell", bundle: nil)
        destinationsTableView.register(nib,
                forCellReuseIdentifier: "DestinationCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposeDestinationSegue" {
                /* TODO: Implement creating a new destination functionality in
                 *       DestinationComposerViewController.
                 */
            } else if identifier == "ShowDestinationDetailSegue" {
                let viewController = segue.destination as! PlansViewController
                viewController.destination = destination
            }
        }
    }

    @IBAction func showHome(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func createDestination(_ sender: Any) {
        performSegue(withIdentifier: "ComposeDestinationSegue", sender: nil)
    }
}

extension DestinationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int {
        return testDestinationNames.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: "DestinationCell", for: indexPath)
                as! DestinationCell

        cell.nameLabel.text = testDestinationNames[indexPath.row]
        cell.dateRangeLabel.text = testDateRanges[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath) {
        /* DEBUG CODE BEG */
        let destinationIDs = [
            "DeF9ZptxgR",
            "VYVVzWh1Fe",
            "x8bNwUdH2y",
            "xSHTpCLLlm"
        ]
        let query = PFQuery(className: "Destination")
        /* BAD: Highly possible blocking the main thread! */
        destination = try? query.getObjectWithId(destinationIDs[indexPath.row])
        /*
        query.getObjectInBackground(withId: destinationIDs[indexPath.row]) {
                (destination, error) in
                    if destination != nil {
                        self.destination = destination
                    }
                }
        */
        /* DEBUG CODE END */

        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "ShowDestinationDetailSegue",
                sender: tableView.cellForRow(at: indexPath))
    }
}
