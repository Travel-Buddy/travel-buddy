//
//  CarRentalPlanComposerViewController.swift
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

class CarRentalPlanComposerViewController: PlanComposerViewController {
    override func loadUI() {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "MMM d, yyyy hh:mm a"

        form
            +++ Section("Company")
            <<< GooglePlacesTableRow() {
                $0.tag = "estabName"
                $0.placeFilter?.type = .establishment
                $0.placeBounds = coordinateBounds
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                if let plan = plan,
                   let name = plan["estabName"] as? String {
                    $0.value = GooglePlace(string: name)
                    $0.cell.isUserInteractionEnabled = false
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

            +++ Section("Pick Up")
            <<< DateTimeInlineRow() {
                $0.tag = "startDate"
                $0.title = "Time"
                $0.dateFormatter = dateTimeFormatter
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

                $0.onChange { (pickUpDateRow: DateTimeInlineRow) in
                    let dropOffDateRow = self.form.rowBy(tag: "endDate")
                            as! DateTimeInlineRow
                    dropOffDateRow.minimumDate = pickUpDateRow.value

                    if dropOffDateRow.value! <= pickUpDateRow.value! {
                        dropOffDateRow.value = Date(timeInterval: 60 * 60 * 24,
                                since: pickUpDateRow.value!)
                        dropOffDateRow.updateCell()
                    }
                }
            }
            <<< GooglePlacesTableRow() {
                $0.tag = "startLocation"
                $0.title = "Location"
                $0.placeFilter?.type = .address
                $0.placeBounds = coordinateBounds
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                if let plan = plan,
                   let location = plan["startLocation"] as? String {
                    $0.value = GooglePlace(string: location)
                    $0.cell.isUserInteractionEnabled = false
                }
                $0.cell.tableView?.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.customizeTableViewCell = { cell in
                    cell.backgroundColor = UIColor.FlatColor.White.Background
                    cell.textLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                    cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                }
                
                $0.cell.numberOfCandidates = 4
            }
            <<< PhoneRow() {
                $0.tag = "startContact"
                $0.title = "Phone"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                if let plan = plan,
                   let phoneNo = plan["estabContact"] as? String {
                    $0.value = phoneNo
                }
            }

            +++ Section("Drop Off")
            <<< DateTimeInlineRow() {
                $0.tag = "endDate"
                $0.title = "Time"
                $0.dateFormatter = dateTimeFormatter
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.minimumDate = destination["startDate"] as? Date
                /* Handle cases when returning car at the end of trip */
                $0.maximumDate = Date(timeInterval: 60 * 60 * 24,
                            since: trip["endDate"] as! Date)

                /* Handle cases when users enter the same start and end dates */
                if let minDate = $0.minimumDate,
                   let maxDate = $0.maximumDate,
                   minDate == maxDate {
                    $0.maximumDate = Date(timeInterval: 60 * 60 * 24,
                            since: minDate)
                }

                if let plan = plan,
                   let dropOffDate = plan["endDate"] as? Date {
                    $0.value = dropOffDate
                } else {
                    $0.value = Date(timeInterval: 60 * 60 * 24,
                            since: $0.minimumDate ?? Date())
                }
            }
            <<< CheckRow() {
                $0.tag = "sameEndLocation"
                $0.title = "Return to same location"
                $0.value = true
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
            }
            <<< GooglePlacesTableRow() {
                $0.tag = "endLocation"
                $0.title = "Location"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.placeFilter?.type = .address
                $0.placeBounds = coordinateBounds
                $0.hidden = Condition.function(["sameEndLocation"]) {
                        (form: Form) -> Bool in
                            let sameEndLocationRow = form.rowBy(
                                    tag: "sameEndLocation") as? CheckRow
                            return sameEndLocationRow?.value ?? true
                        }
                $0.cell.tableView?.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.customizeTableViewCell = { cell in
                    cell.backgroundColor = UIColor.FlatColor.White.Background
                    cell.textLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                    cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                }
                
                $0.cell.numberOfCandidates = 4
                if let plan = plan,
                   let dropOffLocation = plan["endLocation"] as? String {
                    $0.value = GooglePlace(string: dropOffLocation)
                    $0.cell.isUserInteractionEnabled = false
                }
            }
            <<< PhoneRow() {
                $0.tag = "endContact"
                $0.title = "Phone"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.hidden = Condition.function(["sameEndLocation"]) {
                        (form: Form) -> Bool in
                            let sameEndLocationRow = form.rowBy(
                                    tag: "sameEndLocation") as? CheckRow
                            return sameEndLocationRow?.value ?? true
                        }
                
                if let plan = plan,
                   let phoneNo = plan["name"] as? String {
                    $0.value = phoneNo
                }
            }

            +++ Section("Confirmation Number")
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

            +++ createUIStageSection()

        if plan == nil {
            let nameRow = form.rowBy(tag: "estabName") as! GooglePlacesTableRow
            nameRow.cell.textField.becomeFirstResponder()
        }
    }

    override func updateUIGPTableRows() {
        let nameRow = form.rowBy(tag: "estabName") as! GooglePlacesTableRow
        nameRow.placeBounds = coordinateBounds

        let pickUpLocationRow = form.rowBy(tag: "startLocation")
                as! GooglePlacesTableRow
        pickUpLocationRow.placeBounds = coordinateBounds

        let dropOffLocationRow = form.rowBy(tag: "endLocation")
                as! GooglePlacesTableRow
        dropOffLocationRow.placeBounds = coordinateBounds
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
                                    self.displayAlert(
                                            message: error.localizedDescription)
                                } else if let place = place {
                                    self.updateUILocationUsingGPPlace(place)
                                }
                            }
                }
            }
        }
    }

    func updateUILocationUsingGPPlace(_ place: GooglePlacePlace) {
        let pickUpLocationRow = form.rowBy(tag: "startLocation")
                as! GooglePlacesTableRow
        pickUpLocationRow.value = GooglePlace(string: place.address!)
        pickUpLocationRow.reload()
        
        let pickUpPhoneNoRow = form.rowBy(tag: "startContact") as! PhoneRow
        pickUpPhoneNoRow.value = place.phoneNo
        pickUpPhoneNoRow.reload()
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

        if let pickUpDate = dictionary["startDate"] as? Date {
            editedPlan["startDate"] = pickUpDate
        }
        if let place = dictionary["startLocation"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                editedPlan["startLocation"] = value
            case let GooglePlace.prediction(prediction: prediction):
                editedPlan["startLocation"] =
                        prediction.attributedFullText.string
            }
        }
        if let pickUpPhoneNo = dictionary["startContact"] as? String {
            editedPlan["estabContact"] = pickUpPhoneNo
        }

        if let dropOffDate = dictionary["endDate"] as? Date {
            editedPlan["endDate"] = dropOffDate
        }
        if dictionary["sameEndLocation"] as? Bool ?? true {
            editedPlan["endLocation"] = editedPlan["startLocation"]
            editedPlan["name"] = editedPlan["estabContact"]
        } else {
            if let place = dictionary["endLocation"] as? GooglePlace {
                switch place {
                case let GooglePlace.userInput(value: value):
                    editedPlan["endLocation"] = value
                case let GooglePlace.prediction(prediction: prediction):
                    editedPlan["endLocation"] =
                            prediction.attributedFullText.string
                }
            }
            if let dropOffPhoneNo = dictionary["endContact"] as? String {
                editedPlan["name"] = dropOffPhoneNo
            }
        }

        if let confirmationNo = dictionary["estabVerifyNbr"] as? String {
            editedPlan["estabVerifyNbr"] = confirmationNo
        }

        /* Do not overwrite when editing existing plans */
        if initialPlan == nil {
            editedPlan["planType"] = "car_rental"
            editedPlan["planStage"] = "proposal"
        }

        return editedPlan
    }
}
