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
import GooglePlacesRow
import Parse

/* DEBUG CODE BEG */
/* Filter type: Points of Interest */
/*
let (debugNamePlaceFilterType, debugLocationPlaceFilterType) =
    (GMSPlacesAutocompleteTypeFilter.establishment,
     GMSPlacesAutocompleteTypeFilter.address)
*/
/* Filter type: Natural Features */

let (debugNamePlaceFilterType, debugLocationPlaceFilterType) =
    (GMSPlacesAutocompleteTypeFilter.geocode,
     GMSPlacesAutocompleteTypeFilter.region)

/* DEBUG CODE END */


@objc protocol PlanComposerViewControllerDelegate {
    @objc optional func planComposerViewController(
            _ planComposerViewController: PlanComposerViewController,
            didSavePlan plan: PFObject)
}

class PlanComposerViewController: FormViewController {
    weak var delegate: PlanComposerViewControllerDelegate?

    var destination: PFObject!
    var plan: PFObject?
    
    var coordinateBounds: GMSCoordinateBounds?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form
            +++ Section("Name")
            <<< GooglePlacesTableRow() {
                $0.tag = "EstablishmentName"
                $0.placeFilter?.type = debugNamePlaceFilterType
                $0.placeBounds = self.coordinateBounds
                
                if let plan = self.plan,
                    let name = plan["estabName"] as? String {
                    $0.value = GooglePlace(string: name)
                }
            }
            .onChange(updateFormUsingGooglePlacesTableRow)
            
            +++ Section("Location")
            <<< GooglePlacesTableRow() {
                $0.tag = "EstablishmentLocation"
                $0.placeFilter?.type = debugLocationPlaceFilterType
                $0.placeBounds = self.coordinateBounds
                
                if let plan = self.plan,
                    let location = plan["estabLocation"] as? String {
                    $0.value = GooglePlace(string: location)
                }
            }
            
            +++ Section("Phone Number")
            <<< PhoneRow() {
                $0.tag = "EstablishmentContact"
                
                if let plan = self.plan,
                    let phoneNo = plan["estabContact"] as? String {
                    $0.value = phoneNo
                }
            }
            
            +++ Section()
            <<< DateRow() {
                $0.tag = "StartDate"
                $0.title = "Date"
                
                let minDate = self.destination["startDate"] as? Date ?? Date()
                let maxDate = self.destination["endDate"] as? Date
                $0.minimumDate = minDate
                $0.maximumDate = maxDate
                
                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = TimeZone(abbreviation: "UTC")!
                $0.value = calendar.date(bySettingHour: 12, minute: 0,
                        second: 0, of: minDate)
            }
        
        let nameRow = self.form.rowBy(tag: "EstablishmentName")
                as! GooglePlacesTableRow
        nameRow.cell.textField.becomeFirstResponder()
        
        /* Get coordinate bounds to be used in autocomplete function */
        if let destinationName = destination["title"] as? String {
            GooglePlacesAPIController.shared.getGeocode(
            address: destinationName) {
                (destinations: [GooglePlaceDestination]?, error: Error?) in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                } else if destinations != nil {
                    for destination in destinations! {
                        self.updateCoordinateBoundsUsingGPDestination(
                            destination)
                        /* Use the first destination */
                        break
                    }
                }
            }
        }
    }
    
    private func updateCoordinateBoundsUsingGPDestination(
            _ destination: GooglePlaceDestination) {
        coordinateBounds = GMSCoordinateBounds(
                coordinate:  CLLocationCoordinate2D(
                        latitude: destination.geometryViewportNELat,
                        longitude: destination.geometryViewportNELng),
                coordinate: CLLocationCoordinate2D(
                        latitude: destination.geometryViewportSWLat,
                        longitude: destination.geometryViewportSWLng))
        
        let nameRow = form.rowBy(tag: "EstablishmentName")
                as! GooglePlacesTableRow
        nameRow.placeBounds = coordinateBounds
        
        let locationRow = form.rowBy(tag: "EstablishmentLocation")
                as! GooglePlacesTableRow
        locationRow.placeBounds = coordinateBounds
    }
    
    func updateFormUsingGooglePlacesTableRow(row: GooglePlacesTableRow) {
        let dictionary = form.values()
        
        if let place = dictionary["EstablishmentName"] as? GooglePlace {
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
                                    let locationRow = self.form.rowBy(
                                        tag: "EstablishmentLocation")
                                        as! GooglePlacesTableRow
                                    locationRow.value = GooglePlace(
                                        string: place.address!)
                                    locationRow.reload()
                                    
                                    let phoneNoRow = self.form.rowBy(
                                        tag: "EstablishmentContact")
                                        as! PhoneRow
                                    phoneNoRow.value = place.phoneNo
                                    phoneNoRow.reload()
                                }
                            }
                }
            }
        }
    }
    
    private func composePlan(_ plan: PFObject) -> PFObject {
        let dictionary = form.values()
        
        if let place = dictionary["EstablishmentName"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                plan["estabName"] = value
            case let GooglePlace.prediction(prediction: prediction):
                plan["estabName"] = prediction.attributedPrimaryText.string
            }
        }
        
        if let place = dictionary["EstablishmentLocation"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                plan["estabLocation"] = value
            case let GooglePlace.prediction(prediction: prediction):
                plan["estabLocation"] = prediction.attributedFullText.string
            }
        }
        
        if let phoneNo = dictionary["EstablishmentContact"] as? String {
            plan["estabContact"] = phoneNo
        }
        
        if let date = dictionary["StartDate"] as? Date {
            plan["startDate"] = date
        }

        /* Prevent overwriting the followings when editing existing plans */
        if self.plan == nil {
            plan["planType"] = "natural_feature"
            plan["planStage"] = "proposal"
            plan["createdBy"] = PFUser.current()
            plan["destination"] = destination
        }
        
        return plan
    }
    
    private func addRelationPlan(_ plan: PFObject,
            withDestination destination: PFObject) {
        let relation = destination.relation(forKey: "plans")
        relation.add(plan)
        destination.saveInBackground {
                (success: Bool, error: Error?) in
                    if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    } else if success {
                        self.delegate?.planComposerViewController?(self,
                                didSavePlan: plan)
                    }
                }
    }
    
    private func savePlan() {
        let query = PFQuery(className: "Plan")
        query.getObjectInBackground(withId: plan?.objectId ?? "") {
                (plan: PFObject?, error: Error?) in
                    let composedPlan = self.composePlan(
                        (error == nil && plan != nil ? plan! :
                         PFObject(className: "Plan")))
                    
                    composedPlan.saveInBackground {
                            (success: Bool, error: Error?) in
                                if let error = error {
                                    print("ERROR: \(error.localizedDescription)")
                                } else if success {
                                    self.addRelationPlan(composedPlan,
                                            withDestination: self.destination)
                                }
                            }
                }
    }
    
    @IBAction func cancelChanges(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        savePlan()
        dismiss(animated: true, completion: nil)
    }
}
