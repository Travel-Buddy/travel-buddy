//
//  DestinationComposerViewController.swift
//  Travel With Friends
//
//  Created by Janvier Wijaya on 4/30/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Eureka
import GooglePlacesRow
import Parse
import UIKit

class DestinationComposerViewController: FormViewController {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!

    var trip: PFObject?
    var destination: PFObject?
    var user: PFUser?

    var minDate: Date?
    var maxDate: Date?

    var isEditingDestination: Bool = false

    var valuesDictionary = [String: Any?]()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let trip = trip {
            minDate = trip["startDate"] as? Date
            maxDate = trip["endDate"] as? Date
        }
        
        if let font = UIFont(name: "FontAwesome", size: 19) {
            cancelButton.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
            cancelButton.title = String.Fontawesome.Cancel
            saveButton.setTitleTextAttributes(
                [NSFontAttributeName: font], for: .normal)
            saveButton.title = String.Fontawesome.Save
        }

        guard destination != nil else {
            user = PFUser.current()
            layoutDestinationForm()
            return
        }

        
        tableView.backgroundColor = UIColor.FlatColor.White.Background

        loadDestination()
    }

    @IBAction func cancelChanges(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveChanges(_ sender: Any) {
        if form.rowBy(tag: "title")?.baseValue != nil {
            dismiss(animated: true) {
                self.saveDestination()
            }
        } else {
            displayAlert(message: "The destination name cannot be blank")
        }
    }

    func layoutDestinationForm() {
        form
            +++ Section("Destination")
            <<< GooglePlacesTableRow {
                $0.tag = "title"
                
                $0.placeholder = "Enter destination"
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                

                if let destination = destination {
                    if let title = destination["title"] as? String {
                        $0.value = GooglePlace.userInput(value: title)

                        if let subtitle = destination["subtitle"] as? String {
                            if subtitle != "" {
                                $0.value = GooglePlace.userInput(value: title + " - " + subtitle)
                            }
                        }
                    }
                    $0.cell.isUserInteractionEnabled = false
                }

                $0.placeFilter?.type = .city
                $0.onNetworkingError = { error in
                    if let error = error {
                        self.displayAlert(message: error.localizedDescription)
                    }
                }
                $0.cell.tableView?.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.customizeTableViewCell = { cell in
                    cell.backgroundColor = UIColor.FlatColor.White.Background
                    cell.textLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                    cell.textLabel?.textColor = UIColor.FlatColor.Green.Subtext
                }
                
                $0.cell.numberOfCandidates = 4
                
            }

            +++ Section("Destination Dates")
            <<< DateInlineRow {
                $0.tag = "startDate"
                $0.title = "Start Date"
                $0.value = destination?["startDate"] as? Date ?? minDate
                $0.minimumDate = minDate
                $0.maximumDate = maxDate
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                $0.cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText

                $0.onChange({ (startDate) in
                    if let endDate: DateInlineRow = self.form.rowBy(tag: "endDate") {
                        endDate.minimumDate = startDate.value

                        if endDate.value!.compare(startDate.value!) == .orderedAscending {
                            endDate.value = startDate.value
                            endDate.updateCell()
                        }
                    }
                })
            }
            <<< DateInlineRow {
                $0.tag = "endDate"
                $0.title = "End Date"
                $0.value = destination?["endDate"] as? Date ?? minDate
                $0.minimumDate = minDate
                $0.maximumDate = maxDate
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                $0.cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
            }

            +++ Section("Created By")
            
            <<< LabelRow() {
                $0.tag = "createdBy"
                $0.title = user!.value(forKey: "name") as? String
                $0.cell.backgroundColor = UIColor.FlatColor.White.Background
                $0.cell.textLabel?.font = UIFont.Subheadings.TripComposeUserTitleText
                $0.cell.detailTextLabel?.font = UIFont.Subheadings.TripComposeUserSubText
                
                }.cellUpdate({ (cell, row) in
                    cell.textLabel?.textColor = UIColor.FlatColor.Blue.MainText
                    cell.alpha = 1.0
                })
            

    }

    func saveDestination() {
        valuesDictionary = form.values()

        var destinationToSave: PFObject!

        let destinationQuery = PFQuery(className: "Destination")
        destinationQuery.getObjectInBackground(withId: (self.destination?.objectId ?? "")!) { (destination, error) in
            if let destination = destination {
                destinationToSave = destination
            } else {
                destinationToSave = PFObject(className: "Destination")
            }

            let place = self.valuesDictionary["title"] as! GooglePlace

            if !self.isEditingDestination {
                switch place {
                case let GooglePlace.userInput(value: value):
                    destinationToSave["title"] = value
                    destinationToSave["subtitle"] = ""
                case let GooglePlace.prediction(prediction: prediction):
                    destinationToSave["title"] = prediction.attributedPrimaryText.string
                    destinationToSave["subtitle"] = prediction.attributedSecondaryText?.string
                }
            }

            destinationToSave["startDate"] = (self.valuesDictionary["startDate"] as! Date).removeTimeComponent()
            destinationToSave["endDate"] = (self.valuesDictionary["endDate"] as! Date).removeTimeComponent()
            destinationToSave["trip"] = self.trip
            destinationToSave["createdBy"] = self.user
            destinationToSave.saveInBackground { (success, error) in
                if let error = error {
                    self.displayAlert(message: error.localizedDescription)
                } else {
                    let tripRelation = self.trip!.relation(forKey: "destinations")
                    tripRelation.add(destinationToSave)
                    self.trip!.saveInBackground { (success, error) in
                        if let error = error {
                            self.displayAlert(message: error.localizedDescription)
                        } else {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadDestinations"), object: nil)
                        }
                    }
                }
            }
        }
    }

    func loadDestination() {
        let userId = (destination!["createdBy"] as? PFUser)?.objectId

        let userQuery = PFUser.query()
        userQuery?.whereKey("objectId", equalTo: userId!)
        userQuery?.getFirstObjectInBackground(block: { (user, error) in
            if let user = user {
                self.user = user as? PFUser
                self.layoutDestinationForm()
            } else if let error = error {
                self.displayAlert(message: error.localizedDescription)
            }
        })
    }

    func displayAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }

}

public extension Date {

    func removeTimeComponent() -> Date {
        let calendar = Calendar.autoupdatingCurrent
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: self)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        return calendar.date(from: dateComponents)!
    }

    func asString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: self)
    }

}

public extension Double {

    func asFormattedCurrency() -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.locale = Locale.current
        currencyFormatter.maximumFractionDigits = 2
        currencyFormatter.minimumFractionDigits = 2
        currencyFormatter.numberStyle = NumberFormatter.Style.currency
        currencyFormatter.usesGroupingSeparator = true
        return currencyFormatter.string(for: self)!
    }

}
