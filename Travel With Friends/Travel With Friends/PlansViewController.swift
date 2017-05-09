//
//  PlansViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//
import UIKit

import Parse

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

class PlansViewController: UITableViewController {
    @IBOutlet weak var addBarButtonItem: UIBarButtonItem!

    var destination: PFObject!

    let planStages = [
        "finalized",
        "proposal"
    ]
    let planStageTitles = [
        "finalized" : "Finalized Plans",
        "proposal" : "Proposed Plans"
    ]
    var plans = [
        "finalized" : [PFObject](),
        "proposal" : [PFObject]()
    ]

    var selectedIndexPath: IndexPath?

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

        /* Allow pull to refresh */
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refreshPlans(_:)),
                for: .valueChanged)
        tableView.insertSubview(refreshControl!, at: 0)

        refreshPlans(refreshControl!)
    }

    func refreshPlans(_ refreshControl: UIRefreshControl) {
        let query = PFQuery(className: "Plan")
        query.whereKey("destination", equalTo: destination)
        query.order(byAscending: "planStage, startDate, createdAt")
        query.findObjectsInBackground {
                (objects: [PFObject]?, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else if let objects = objects {
                        for stage in self.planStages {
                            self.plans[stage]?.removeAll()
                        }
                        for object in objects {
                            if let stage = object["planStage"] as? String {
                                self.plans[stage]?.append(object)
                            }
                        }
                        self.tableView.reloadData()
                    }
                    refreshControl.endRefreshing()
                }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposePlanSegue" {
                var viewController: PlanComposerViewController
                if let navigationController = segue.destination
                           as? UINavigationController {
                    viewController = navigationController.topViewController
                            as! PlanComposerViewController
                } else {
                    viewController = segue.destination
                            as! PlanComposerViewController
                }
                viewController.delegate = self
                viewController.destination = destination
            } else if identifier == "ShowPlanDetailSegue" {
                let viewController = segue.destination
                        as! DetailedPlanViewController
                let cell = sender as! UITableViewCell
                let indexPath = tableView.indexPath(for: cell)!
                let stage = planStages[indexPath.section]
                viewController.delegate = self
                viewController.destination = destination
                viewController.plan = plans[stage]![indexPath.row]
                selectedIndexPath = indexPath
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
            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
                withIdentifier: "PlanCell", for: indexPath) as! PlanCell
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

    override func tableView(_ tableView: UITableView,
            canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView,
            commit editingStyle: UITableViewCellEditingStyle,
            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let stage = planStages[indexPath.section]
            let plan = plans[stage]![indexPath.row]

            plan.deleteInBackground { (success: Bool, error: Error?) in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                } else if success {
                    self.refreshPlans(self.refreshControl!)
                }
            }
        }
    }
}

extension PlansViewController: PlanComposerViewControllerDelegate {
    func planComposerViewController(
            _ planComposerViewController: PlanComposerViewController,
            didSavePlan plan: PFObject) {
        if plans["proposal"] != nil {
            plans["proposal"]!.insert(plan, at: 0)
            tableView.reloadData()
        }
    }
}

extension PlansViewController: DetailedPlanViewControllerDelegate {
    func detailedPlanViewController(
            _ detailedPlanViewController: DetailedPlanViewController,
            didEditPlan plan: PFObject) {
        if let indexPath = selectedIndexPath {
            let curStage = planStages[indexPath.section]
            if let newStage = plan["planStage"] as? String {
                if newStage != curStage {
                    /* NOTE: Let DB handle it for now */
                    refreshPlans(refreshControl!)
                } else {
                    plans[curStage]![indexPath.row] = plan
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }
            }
            selectedIndexPath = nil
        }
    }
}
