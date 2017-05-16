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
            didSavePlan plan: PFObject, asUpdate update: Bool)
}

class PlanComposerViewController: FormViewController {
    weak var delegate: PlanComposerViewControllerDelegate?

    var trip: PFObject!
    var destination: PFObject!
    var plan: PFObject?

    var coordinateBounds: GMSCoordinateBounds?

    var tripParticipants = [String : PFUser]()

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
            /* FIX ME: Need to differentiate between header and cell row */
            row.baseCell.backgroundColor =
                    UIColor.FlatColor.White.Background
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

    func createUICostSection() -> Section {
        return Section("Total Cost")
            <<< DecimalRow() {
                $0.tag = "cost"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                let formatter = CurrencyFormatter()
                formatter.locale = .current
                formatter.numberStyle = .currency
                $0.formatter = formatter
                $0.useFormatterDuringInput = true

                if let plan = plan,
                   let cost = plan["cost"] as? Double {
                    $0.value = cost
                } else {
                    $0.value = 0.00
                }
            }
    }

    func createUIParticipantsSection() -> Section {
        tableView.isEditing = false

        let section = MultivaluedSection(multivaluedOptions: .Delete,
                header: "Participants") {
            $0.tag = "participants"
        }

        let relation = (plan == nil ? trip.relation(forKey: "users") :
                plan!.relation(forKey: "participants"))
        relation.query().findObjectsInBackground {
                (users: [PFObject]?, error: Error?) in
                    guard error == nil else {
                        self.displayAlert(message: error!.localizedDescription)
                        return
                    }

                    guard let users = users else {
                        return
                    }

                    self.tripParticipants.removeAll()
                    let currentUser = PFUser.current()!
                    section <<< LabelRow() {
                        $0.tag = currentUser.objectId
                        $0.title = currentUser["name"] as? String
                        $0.cell.isUserInteractionEnabled = false
                        $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                        $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                        $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                        
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
                            cell.alpha = 1.0
                        })
            
                    self.tripParticipants[currentUser.objectId!] = currentUser
                    for user in users {
                        if user.objectId == currentUser.objectId {
                            continue
                        }
                        section <<< LabelRow() {
                            $0.tag = user.objectId
                            $0.title = user["name"] as? String
                            $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                            $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                            $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                            
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
                                cell.alpha = 1.0
                            })
                        
                        self.tripParticipants[user.objectId!] = user as? PFUser
                    }
                }

        return section
    }

    func createUIStageSection() -> Section {
        return Section()
            <<< ButtonRow() {
                $0.tag = "stage"
                if let stage = self.plan?["planStage"] as? String {
                    if stage == "proposal" {
                        $0.title = "Finalize Plan"
                    } else if stage == "finalized" {
                        $0.title = "Reconsider Plan"
                    }
                }

                $0.hidden = Condition.function([]) {
                        (form: Form) -> Bool in
                            return self.plan == nil
                        }
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.tintColor = UIColor.FlatColor.Green.Subtext
                $0.cell.textLabel?.font = UIFont.Buttons.ProfilePageButton

                $0.onCellSelection {
                        (cell: ButtonCellOf<String>, row: (ButtonRow)) in
                            if let stage = self.plan?["planStage"] as? String {
                                if stage == "proposal" {
                                    self.plan?["planStage"] = "finalized"
                                } else if stage == "finalized" {
                                    self.plan?["planStage"] = "proposal"
                                }
                                self.plan?.saveInBackground {
                                        (success: Bool, error: Error?) in
                                            if let error = error {
                                                self.displayAlert(
                                                        message: error.localizedDescription)
                                            } else if success {
                                                if stage == "proposal" {
                                                    row.title = "Reconsider Plan"
                                                } else if stage == "finalized" {
                                                    row.title = "Finalize Plan"
                                                }
                                                row.updateCell()
                                                self.delegate?.planComposerViewController?(
                                                        self, didSavePlan: self.plan!,
                                                        asUpdate: true)
                                            }
                                        }
                            }
                        }
            }
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
        let editedPlan: PFObject
        if initialPlan != nil {
            editedPlan = initialPlan!
        } else {
            editedPlan = PFObject(className: "Plan")
            editedPlan["createdBy"] = PFUser.current()
            editedPlan["destination"] = destination
        }

        let dictionary = form.values()
        if let cost = dictionary["cost"] as? Double {
            editedPlan["cost"] = cost
        }

        if let participantsSection = form.sectionBy(tag: "participants")
                   as? MultivaluedSection {
            var planParticipantIds = [String]()
            for row in participantsSection.enumerated() {
                if let tag = row.element.tag {
                    planParticipantIds.append(tag)
                }
            }

            let relation = editedPlan.relation(forKey: "participants")
            for (tripParticipantId, tripParticipant) in tripParticipants {
                if planParticipantIds.index(of: tripParticipantId) == nil {
                    relation.remove(tripParticipant)
                } else {
                    relation.add(tripParticipant)
                }
            }
        }

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
                                 didSavePlan: editedPlan, asUpdate: false)
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
                                            self, didSavePlan: plan!,
                                            asUpdate: true)
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
