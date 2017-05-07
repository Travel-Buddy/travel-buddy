//
//  PlansViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Parse
import UIKit

class PlansViewController: UIViewController {
    @IBOutlet weak var plansTableView: UITableView!
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!

    /* begin temporary codeblock */
    var destination: PFObject?
    /* end temporary code block */

    let testPlanStages = [
        "Finalized Plans",
        "Proposed Plans"
    ]
    let testPlanNames = [
        [
            "!! San Diego (SAN) - Salt Lake City (SLC)",
            "!! Avis Car Rental",
            "Kelly Inn-West Yellowstone"
        ],
        [
            "Hotel ABC",
            "Temple Square",
            "Old Faithful",
            "Mammoth Hot Springs",
            "Jenny Lake",
            "Jackson Lake",
            "Hotel XYZ",
        ]
    ]
    let testPlanLocations = [
        [
            "!! Delta Air Lines 2546",
            "!! Pick-up at 11:30PM at 656 3800 W, Salt Lake City, UT 84116, USA",
            "104 S Canyon St, West Yellowstone, MT 59758, USA",
        ],
        [
            "1234 S Unknown Rd, Salt Lake City, UT 84150, USA",
            "50 N Temple, Salt Lake City, UT 84150, USA",
            "Yellowstone National Park, WY 82190, USA",
            "Yellowstone National Park, WY 82190, USA",
            "Jenny Lake, Wyoming 83414, USA",
            "Jackson Lake, Wyoming 83013, USA",
            "9876 N Random Rd, Salt Lake City, UT 84150, USA"
        ]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        /* begin temporary codeblock */
        print(destination!)
        /* end temporary code block */

        /* Use 'fa-plus' text icon from FontAwesome.
         * http://fontawesome.io/cheatsheet/
         */
        if let font = UIFont(name: "FontAwesome", size: 17) {
            addBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            addBarButtonItem.title = "\u{f067}"
        }

        plansTableView.dataSource = self
        plansTableView.delegate = self
        plansTableView.rowHeight = UITableViewAutomaticDimension
        plansTableView.estimatedRowHeight = 99

        plansTableView.register(UITableViewHeaderFooterView.self,
                forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")

        let nib = UINib(nibName: "PlanCell", bundle: nil)
        plansTableView.register(nib,
                forCellReuseIdentifier: "PlanCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposePlanSegue" {
                /* TODO: Implement creating a new plan functionality in
                 *       PlanComposerViewController
                 */
            } else if identifier == "ShowPlanDetailSegue" {
            }
        }
    }

    @IBAction func createPlan(_ sender: Any) {
        performSegue(withIdentifier: "ComposePlanSegue", sender: nil)
    }
}

extension PlansViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return testPlanStages.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int {
        return testPlanNames[section].count
    }

    func tableView(_ tableView: UITableView,
            viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: "TableViewHeaderView")!

        header.textLabel?.text = testPlanStages[section]

        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlanCell", for: indexPath)
                as! PlanCell

        cell.nameLabel.text = testPlanNames[indexPath.section][indexPath.row]
        cell.locationLabel.text =
                testPlanLocations[indexPath.section][indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView,
            heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }

    func tableView(_ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "ShowPlanDetailSegue",
                sender: tableView.cellForRow(at: indexPath))
    }
}
