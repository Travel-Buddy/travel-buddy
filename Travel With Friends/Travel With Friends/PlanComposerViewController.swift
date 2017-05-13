//
//  PlanComposerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//
import UIKit

import Eureka
import GooglePlaces
import Parse

@objc protocol PlanComposerViewControllerDelegate {
    @objc optional func planComposerViewController(
            _ planComposerViewController: PlanComposerViewController,
            didSavePlan plan: PFObject)
}

class PlanComposerViewController: FormViewController {
    weak var delegate: PlanComposerViewControllerDelegate?

    var trip: PFObject!
    var destination: PFObject!
    var plan: PFObject?

    var participants = [PFUser]()

    var coordinateBounds: GMSCoordinateBounds?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.FlatColor.White.Background
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadUI()

        /* Get coordinate bounds to be used in autocomplete function */
        if let destinationName = destination["title"] as? String {
            GooglePlacesAPIController.shared.getGeocode(
                    address: destinationName) {
                    (gpDestinations: [GooglePlaceDestination]?,
                            error: Error?) in
                        if let error = error {
                            print("ERROR: \(error.localizedDescription)")
                        } else if let gpDestination = gpDestinations?.first {
                            self.updateCoordinateBoundsUsingGPDestination(
                                    gpDestination)
                        }
                    }
        }

        for row in form.rows {
            /* FIX ME: Need to differentiate between header and cell row
            row.baseCell.backgroundColor =
                    UIColor.FlatColor.White.Background
            */
            row.baseCell.textLabel?.font =
                    UIFont.Subheadings.TripComposeUserTitleText
            row.baseCell.textLabel?.textColor =
                    UIColor.FlatColor.Blue.MainText
            row.baseCell.detailTextLabel?.font =
                    UIFont.Subheadings.TripComposeUserSubText
        }
    }

    func loadUI() {
        /* void */
    }

    func updateUIGPTableRows() {
        /* void */
    }

    func updateCoordinateBoundsUsingGPDestination(
            _ gpDestination: GooglePlaceDestination) {
        coordinateBounds = GMSCoordinateBounds(
                coordinate:  CLLocationCoordinate2D(
                        latitude: gpDestination.geometryViewportNELat,
                        longitude: gpDestination.geometryViewportNELng),
                coordinate: CLLocationCoordinate2D(
                        latitude: gpDestination.geometryViewportSWLat,
                        longitude: gpDestination.geometryViewportSWLng))
        updateUIGPTableRows()
    }

    func composePlan(_ initialPlan: PFObject?) -> PFObject {
        if initialPlan != nil {
            return initialPlan!
        }

        let editedPlan = PFObject(className: "Plan")
        editedPlan["createdBy"] = PFUser.current()
        editedPlan["destination"] = destination

        return editedPlan
    }

    func addRelation(between editedPlan: PFObject, and destination: PFObject) {
        let relation = destination.relation(forKey: "plans")
        relation.add(editedPlan)
        destination.saveInBackground {
                (success: Bool, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else if success {
                        self.delegate?.planComposerViewController?(self,
                                 didSavePlan: editedPlan)
                        print("Plan is successfully created and saved!")
                    }
                }
    }

    func savePlan() {
        let query = PFQuery(className: "Plan")
        query.getObjectInBackground(withId: plan?.objectId ?? "") {
                (plan: PFObject?, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                        return
                    }

                    let editedPlan = self.composePlan(plan)
                    editedPlan.saveInBackground {
                            (success: Bool, error: Error?) in
                                if let error = error {
                                    print("ERROR: \(error.localizedDescription)")
                                    return
                                } else if !success {
                                    return
                                }

                                if plan == nil {
                                    self.addRelation(between: editedPlan,
                                            and: self.destination)
                                } else {
                                    self.delegate?.planComposerViewController?(
                                            self, didSavePlan: plan!)
                                    print("Plan is successfully edited and saved!")
                                }
                            }
                }
    }

    func displayAlert(message: String) {
        let alertController = UIAlertController(title: "Error",
                message: message, preferredStyle: .alert)
        alertController.addAction(
                UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension PlanComposerViewController {
    class CurrencyFormatter: NumberFormatter, FormatterProtocol {
        override func getObjectValue(
                _ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                for string: String,
                range rangep: UnsafeMutablePointer<NSRange>?) throws {
            guard obj != nil else {
                return
            }

            let str = string.components(
                    separatedBy: CharacterSet.decimalDigits.inverted).joined(
                    separator: "")
            obj?.pointee = NSNumber(value: (Double(str) ?? 0.0) /
                    Double(pow(10.0, Double(minimumFractionDigits))))
        }

        func getNewPosition(forPosition position: UITextPosition,
                inTextInput textInput: UITextInput, oldValue: String?,
                newValue: String?) -> UITextPosition {
            return textInput.position(from: position,
                    offset: ((newValue?.characters.count ?? 0) -
                            (oldValue?.characters.count ?? 0))) ?? position
        }
    }
}
