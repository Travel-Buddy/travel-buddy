//
//  FlightPlanComposerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 5/11/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit

import Eureka
import Parse

class FlightPlanComposerViewController: PlanComposerViewController {
    override func loadUI() {
        let dateTimeFormatter = DateFormatter()
        dateTimeFormatter.dateFormat = "MMM d, yyyy hh:mm a"

        form
            +++ Section("Airline")
            <<< NameRow() {
                $0.tag = "estabName"
                $0.title = "Airline"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background

                if let plan = plan,
                   let airlineName = plan["estabName"] as? String {
                    $0.value = airlineName
                }
            }
            <<< NameRow() {
                $0.tag = "estabNbr"
                $0.title = "Flight number"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background

                if let plan = plan,
                   let flightNo = plan["estabNbr"] as? String {
                    $0.value = flightNo
                }
            }

            +++ Section("Departure")
            <<< NameRow() {
                $0.tag = "startLocation"
                $0.title = "From"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background

                if let plan = plan,
                   let departureLocation = plan["startLocation"] as? String {
                    $0.value = departureLocation
                }
            }
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
                   let departureDate = plan["startDate"] as? Date {
                    $0.value = departureDate
                } else {
                    $0.value = $0.minimumDate ?? Date()
                }

                $0.onChange { (departureDateRow: DateTimeInlineRow) in
                    let arrivalDateRow = self.form.rowBy(tag: "endDate")
                            as! DateTimeInlineRow
                    arrivalDateRow.minimumDate = departureDateRow.value

                    if arrivalDateRow.value! <= departureDateRow.value! {
                        arrivalDateRow.value = Date(timeInterval: 60 * 60 * 24,
                                since: departureDateRow.value!)
                        arrivalDateRow.updateCell()
                    }
                }
            }

            +++ Section("Arrival")
            <<< NameRow() {
                $0.tag = "endLocation"
                $0.title = "To"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                if let plan = plan,
                   let arrivalLocation = plan["endLocation"] as? String {
                    $0.value = arrivalLocation
                }
            }
            <<< DateTimeInlineRow() {
                $0.tag = "endDate"
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
                   let arrivalDate = plan["endDate"] as? Date {
                    $0.value = arrivalDate
                } else {
                    $0.value = $0.minimumDate ?? Date()
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


        let airlineNameRow = form.rowBy(tag: "estabName") as! NameRow
        airlineNameRow.cell.textField.becomeFirstResponder()
    }

    override func composePlan(_ initialPlan: PFObject?) -> PFObject {
        let editedPlan = super.composePlan(initialPlan)
        let dictionary = form.values()

        if let airlineName = dictionary["estabName"] as? String {
            editedPlan["estabName"] = airlineName
        }
        if let flightNo = dictionary["estabNbr"] as? String {
            editedPlan["estabNbr"] = flightNo
        }

        if let departureLocation = dictionary["startLocation"] as? String {
            editedPlan["startLocation"] = departureLocation
        }
        if let departureDate = dictionary["startDate"] as? Date {
            editedPlan["startDate"] = departureDate
        }

        if let arrivalLocation = dictionary["endLocation"] as? String {
            editedPlan["endLocation"] = arrivalLocation
        }
        if let arrivalDate = dictionary["endDate"] as? Date {
            editedPlan["endDate"] = arrivalDate
        }

        if let confirmationNo = dictionary["estabVerifyNbr"] as? String {
            editedPlan["estabVerifyNbr"] = confirmationNo
        }

        /* Do not overwrite when editing existing plans */
        if initialPlan == nil {
            editedPlan["planType"] = "flight"
            editedPlan["planStage"] = "proposal"
        }

        return editedPlan
    }
}
