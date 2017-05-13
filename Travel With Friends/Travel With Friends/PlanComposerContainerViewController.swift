//
//  PlanComposerContainerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 5/11/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Parse

class PlanComposerContainerViewController: UIViewController {
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var contentView: UIView!

    weak var delegate: PlanComposerViewControllerDelegate?

    var destination: PFObject!
    var plan: PFObject?
    var planType: String?

    private var activeViewController: PlanComposerViewController? {
        didSet {
            removeCurrentActiveViewController(oldViewController: oldValue)
            updateCurrentActiveViewController()
        }
    }

    private func removeCurrentActiveViewController(
            oldViewController: PlanComposerViewController?) {
        if let oldActiveViewController = oldViewController {
            oldActiveViewController.willMove(toParentViewController: nil)
            oldActiveViewController.view.removeFromSuperview()
            oldActiveViewController.removeFromParentViewController()
        }
    }

    private func updateCurrentActiveViewController() {
        if let newActiveViewController = activeViewController {
            addChildViewController(newActiveViewController)
            newActiveViewController.view.frame = contentView.bounds
            contentView.addSubview(newActiveViewController.view)
            newActiveViewController.didMove(toParentViewController: self)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let font = UIFont(name: "FontAwesome", size: 19) {
            saveBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            saveBarButtonItem.title = String.Fontawesome.Save
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let planToEdit = plan {
            planType = planToEdit["planType"] as? String
        }

        if planType == "flight" {
            navigationItem.title = "Flight"
            activeViewController = FlightPlanComposerViewController()
        } else if planType == "car_rental" {
            navigationItem.title = "Car Rental"
            activeViewController = CarRentalPlanComposerViewController()
        } else if planType == "accommodation" {
            navigationItem.title = "Accommodation"
            activeViewController = AccommodationPlanComposerViewController()
        } else if planType == "restaurant" {
            navigationItem.title = "Restaurant"
            activeViewController = RestaurantPlanComposerViewController()
        } else if planType == "establishment" {
            navigationItem.title = "Landmark"
            activeViewController = EstablishmentPlanComposerViewController()
        } else if planType == "non-establishment" {
            navigationItem.title = "Other Activity"
            activeViewController = NonEstablishmentPlanComposerViewController()
        } else {
            navigationItem.title = "Other"
            activeViewController = PlanComposerViewController()
        }
        activeViewController?.delegate = delegate
        activeViewController?.destination = destination
        activeViewController?.plan = plan
    }

    @IBAction func cancelChanges(_ sender: Any) {
        if plan == nil {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func saveChanges(_ sender: Any) {
        activeViewController?.savePlan()
        if plan == nil {
            presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
