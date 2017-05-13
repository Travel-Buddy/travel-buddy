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

    var trip: PFObject!
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

        if plan == nil {
            navigationItem.title = "Create Plan"
        } else {
            planType = plan!["planType"] as? String
            navigationItem.title = "Edit Plan"
        }

        if let font = UIFont(name: "FontAwesome", size: 19) {
            saveBarButtonItem.setTitleTextAttributes(
                    [NSFontAttributeName: font], for: .normal)
            saveBarButtonItem.title = String.Fontawesome.Save
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if planType == "flight" {
            activeViewController = FlightPlanComposerViewController()
        } else if planType == "car_rental" {
            activeViewController = CarRentalPlanComposerViewController()
        } else if planType == "accommodation" {
            activeViewController = AccommodationPlanComposerViewController()
        } else if planType == "restaurant" {
            activeViewController = RestaurantPlanComposerViewController()
        } else if planType == "establishment" {
            activeViewController = EstablishmentPlanComposerViewController()
        } else if planType == "non-establishment" {
            activeViewController = NonEstablishmentPlanComposerViewController()
        } else {
            activeViewController = PlanComposerViewController()
        }

        activeViewController?.delegate = delegate
        activeViewController?.trip = trip
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
