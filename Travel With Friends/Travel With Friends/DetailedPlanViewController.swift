//
//  DetailedPlanViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

class DetailedPlanViewController: UIViewController {
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        /* Use 'fa-edit' text icon from FontAwesome.
         * http://fontawesome.io/cheatsheet/
         */
        if let font = UIFont(name: "FontAwesome", size: 17) {
            editBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            editBarButtonItem.title = "\u{f044}"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        /* NOTE: In detailed view, we don't want to have anything at the bottom
         *       so hide the tab bar if this VC is within UITabBarController
         */
        tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        /* NOTE: Put the tab bar back if this VC is within UITabBarController */
        tabBarController?.tabBar.isHidden = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ComposePlanSegue" {
                /* TODO: Implement editing existing plan functionality in
                 *       PlanComposerViewController
                 */
            }
        }
    }

    @IBAction func editPlan(_ sender: Any) {
        performSegue(withIdentifier: "ComposePlanSegue", sender: nil)
    }
}
