//
//  NonEstablishmentPlanComposerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 5/12/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Eureka
import GooglePlaces
import GooglePlacesRow
import Parse

class NonEstablishmentPlanComposerViewController: PlanComposerViewController {
    override func loadUI() {
        form
            +++ Section("Location Name")
            <<< GooglePlacesTableRow() {
                $0.tag = "estabName"
                $0.placeFilter?.type = .geocode
                $0.placeBounds = self.coordinateBounds
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background

                if let plan = self.plan,
                   let name = plan["estabName"] as? String {
                    $0.value = GooglePlace(string: name)
                }
                $0.cell.tableView?.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.customizeTableViewCell = { cell in
                    cell.backgroundColor = UIColor.FlatColor.White.Background
                    cell.textLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                    cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                }
                
                $0.cell.numberOfCandidates = 4
                $0.onChange(updateUILocationUsingGPTableRow)
            }

            +++ Section("Location Region")
            <<< GooglePlacesTableRow() {
                $0.tag = "estabLocation"
                $0.placeFilter?.type = .region
                $0.placeBounds = self.coordinateBounds
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.tableView?.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.customizeTableViewCell = { cell in
                    cell.backgroundColor = UIColor.FlatColor.White.Background
                    cell.textLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                    cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                }
                
                $0.cell.numberOfCandidates = 4
                if let plan = self.plan,
                   let location = plan["estabLocation"] as? String {
                    $0.value = GooglePlace(string: location)
                }
            }

            +++ Section("Visit")
            <<< DateInlineRow() {
                $0.tag = "startDate"
                $0.title = "Date"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background

                $0.minimumDate = destination["startDate"] as? Date
                $0.maximumDate = destination["endDate"] as? Date
                /* Handle cases when users enter the same start and end dates */
                if let minDate = $0.minimumDate,
                   let maxDate = $0.maximumDate,
                   minDate == maxDate {
                    $0.maximumDate = Date(timeInterval: 60 * 60 * 24,
                            since: minDate)
                }

                if let plan = plan,
                   let date = plan["startDate"] as? Date {
                    $0.value = date
                } else {
                    $0.value = $0.minimumDate ?? Date()
                }
            }

            +++ Section("Admission Ticket Number")
            <<< NameRow() {
                $0.tag = "estabVerifyNbr"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background

                if let plan = plan,
                   let confirmationNo = plan["estabVerifyNbr"] as? String {
                    $0.value = confirmationNo
                }
            }

            +++ createUICostSection()


            +++ createUIParticipantsSection()

        let nameRow = form.rowBy(tag: "estabName") as! GooglePlacesTableRow
        nameRow.cell.textField.becomeFirstResponder()
    }

    override func updateUIGPTableRows() {
        let nameRow = form.rowBy(tag: "estabName") as! GooglePlacesTableRow
        nameRow.placeBounds = coordinateBounds

        let locationRow = form.rowBy(tag: "estabLocation")
                as! GooglePlacesTableRow
        locationRow.placeBounds = coordinateBounds
    }

    func updateUILocationUsingGPTableRow(_ row: GooglePlacesTableRow) {
        let dictionary = form.values()

        if let place = dictionary["estabName"] as? GooglePlace {
            switch place {
            case GooglePlace.userInput(value: _):
                break
            case let GooglePlace.prediction(prediction: prediction):
                row.value = GooglePlace(
                        string: prediction.attributedPrimaryText.string)

                if let placeID = prediction.placeID {
                    GooglePlacesAPIController.shared.getPlaceDetail(
                            placeId: placeID) {
                            (place: GooglePlacePlace?, error: Error?) in
                                if let error = error {
                                    print("ERROR: \(error.localizedDescription)")
                                } else if let place = place {
                                    self.updateUILocationUsingGPPlace(place)
                                }
                            }
                }
            }
        }
    }

    func updateUILocationUsingGPPlace(_ place: GooglePlacePlace) {
        let locationRow = form.rowBy(tag: "estabLocation")
                as! GooglePlacesTableRow
        locationRow.value = GooglePlace(string: place.address!)
        locationRow.reload()
    }

    override func composePlan(_ initialPlan: PFObject?) -> PFObject {
        let editedPlan = super.composePlan(initialPlan)
        let dictionary = form.values()

        if let place = dictionary["estabName"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                editedPlan["estabName"] = value
            case let GooglePlace.prediction(prediction: prediction):
                editedPlan["estabName"] =
                        prediction.attributedPrimaryText.string
            }
        }

        if let place = dictionary["estabLocation"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                editedPlan["estabLocation"] = value
            case let GooglePlace.prediction(prediction: prediction):
                editedPlan["estabLocation"] =
                        prediction.attributedFullText.string
            }
        }

        if let date = dictionary["startDate"] as? Date {
            editedPlan["startDate"] = date
        }

        if let confirmationNo = dictionary["estabVerifyNbr"] as? String {
            editedPlan["estabVerifyNbr"] = confirmationNo
        }

        /* Do not overwrite when editing existing plans */
        if initialPlan == nil {
            editedPlan["planType"] = "non-establishment"
            editedPlan["planStage"] = "proposal"
        }

        return editedPlan
    }
}
