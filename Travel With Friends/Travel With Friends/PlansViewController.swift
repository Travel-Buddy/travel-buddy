//
//  PlansViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Parse
import ParseUI

/* DEBUG CODE BEG
let debugPlanStages = [
    "Finalized Plans",
    "Proposed Plans"
]
let debugPlanNames = [
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
let debugPlanLocations = [
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
   DEBUG CODE END */

class PlansViewController: PFQueryTableViewController {
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!

    var shouldReloadObjects = false

    let planStages = ["finalized", "proposal"]

    let planStageTitles = [
        "finalized" : "Finalized Plans",
        "proposal" : "Proposed Plans"
    ]

    var plans = [
        "finalized" : [PFObject](),
        "proposal" : [PFObject]()
    ]

    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)

        parseClassName = "Plan"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        parseClassName = "Plan"
        pullToRefreshEnabled = true
        paginationEnabled = true
        objectsPerPage = 25
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Use 'fa-plus' text icon from FontAwesome.
         * http://fontawesome.io/cheatsheet/
         */
        if let font = UIFont(name: "FontAwesome", size: 17) {
            addBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            addBarButtonItem.title = "\u{f067}"
        }

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 92

        tableView.register(UITableViewHeaderFooterView.self,
                forHeaderFooterViewReuseIdentifier: "TableViewHeaderView")

        let nib = UINib(nibName: "PlanCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "PlanCell")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if shouldReloadObjects {
            loadObjects()
            shouldReloadObjects = false
        }
    }

    override func queryForTable() -> PFQuery<PFObject> {
        let query = PFQuery(className: parseClassName!)

        /* FIX ME: Query based on the selected destination and trip */
        query.whereKey("createdBy", equalTo: PFUser.current()!)

        /* If no objects are loaded in memory, retrieve from the cache first and
         * then subsequently from the network
         */
        if objects!.count == 0 {
            query.cachePolicy = .cacheThenNetwork
        }

        query.order(byAscending: "planStage, startDate, createdAt")

        return query
    }

    override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)

        for stage in planStages {
            plans[stage]?.removeAll()
        }

        for object in objects! {
            if let stage = object["planStage"] as? String {
                plans[stage]?.append(object)
            }
        }
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return planStages.count
    }

    override func tableView(_ tableView: UITableView,
            numberOfRowsInSection section: Int) -> Int {
        let stage = planStages[section]
        if let plansByStage = plans[stage] {
            return plansByStage.count
        }

        return 0
    }

    override func tableView(_ tableView: UITableView,
            viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: "TableViewHeaderView")!
        let stage = planStages[section]
        if let title = planStageTitles[stage] {
          header.textLabel?.text = title
        }

        return header
    }

    override func tableView(_ tableView: UITableView,
            cellForRowAt indexPath: IndexPath, object: PFObject?)
            -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlanCell", for: indexPath)
                as! PlanCell
        let stage = planStages[indexPath.section]
        cell.plan = plans[stage]?[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView,
            heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    override func tableView(_ tableView: UITableView,
            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "ShowPlanDetailSegue",
                sender: tableView.cellForRow(at: indexPath))
    }
}
