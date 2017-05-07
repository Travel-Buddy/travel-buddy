//
//  TripDetailCostsViewController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/23/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import ParseUI
import UIKit

class TripDetailCostsViewController: PFQueryTableViewController {

    @IBOutlet weak var homeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var settingsBarButtonItem: UIBarButtonItem!

    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        parseClassName = "Plan"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        parseClassName = "Plan"
    }

    override func queryForTable() -> PFQuery<PFObject> {
        let planQuery = PFQuery(className: parseClassName!)
        planQuery.whereKey("planStage", equalTo: "finalized")
        planQuery.whereKey("participants", containedIn: [PFUser.current()!])
        planQuery.order(byAscending: "startDate")
        return planQuery
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> PFTableViewCell? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CostCell") as! CostCell

        if object != nil {
            cell.nameLabel.text = object!["name"] as? String

            let startDate = (object!["startDate"] as? Date)!.asString()
            let endDate = (object!["endDate"] as? Date)!.asString()

            if endDate.compare(startDate) == .orderedSame {
                cell.dateRangeLabel.text = startDate
            } else {
                cell.dateRangeLabel.text = startDate + " - " + endDate
            }

            let currencyFormatter = NumberFormatter()
            currencyFormatter.locale = Locale.current
            currencyFormatter.maximumFractionDigits = 2
            currencyFormatter.minimumFractionDigits = 2
            currencyFormatter.numberStyle = NumberFormatter.Style.currency
            currencyFormatter.usesGroupingSeparator = true

            cell.costLabel.text = currencyFormatter.string(from: (object!["cost"] as? NSNumber)!)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
//        performSegue(withIdentifier: "", sender: tableView.cellForRow(at: indexPath))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Use 'fa-home' and 'fa-plus' text icon from FontAwesome.
         * http://fontawesome.io/cheatsheet/
         * NOTE: Intentionally set the two with different size because 'fa-home'
         *       looks slightly smaller than 'fa-plus'.
         */
        if let font = UIFont(name: "FontAwesome", size: 19) {
            homeBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            homeBarButtonItem.title = "\u{f015}"
        }
        if let font = UIFont(name: "FontAwesome", size: 17) {
            settingsBarButtonItem.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            settingsBarButtonItem.title = "\u{f013}"
        }

        let nib = UINib(nibName: "CostCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CostCell")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
//            let cell = sender as! PFTableViewCell
//            let indexPath = tableView.indexPath(for: cell)
//            let plan = object(at: indexPath)
//
//            if identifier == "" {
//                let vc = segue.destination
//                vc.plan = plan
//            }
        }
    }
    
    @IBAction func showHome(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

}
