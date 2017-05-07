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
struct Plan {
    var name = ""
    var address: String?
    var phoneNo: String?
    var date: Date?
}

let debug = true

func debugLog(_ varName: String?, _ varValue: Any?) {
    if !debug {
        return
    }

    if varName == nil {
        print(" ")
    } else if varValue == nil {
        print("\(varName!):")
    } else {
        print("\(varName!): [\(varValue!)]")
    }
}

/* Salt Lake City */
/*
let (debugNELat, debugNELng) = (40.8529699, -111.7394581)
let (debugSWLat, debugSWLng) = (40.700246, -112.101512)
*/
/* Yellowstone National Park */

let (debugNELat, debugNELng) = (45.0553667, -109.927147)
let (debugSWLat, debugSWLng) = (44.1162236, -111.1009672)

/* San Diego */
/*
let (debugNELat, debugNELng) = (33.114249, -116.90816)
let (debugSWLat, debugSWLng) = (32.534856, -117.2821666)
*/

/* Points of Interest */
/*
let (debugNamePlaceFilterType, debugLocationPlaceFilterType) =
        (GMSPlacesAutocompleteTypeFilter.establishment,
         GMSPlacesAutocompleteTypeFilter.address)
*/
/* Natural Features */

let (debugNamePlaceFilterType, debugLocationPlaceFilterType) =
        (GMSPlacesAutocompleteTypeFilter.geocode,
         GMSPlacesAutocompleteTypeFilter.region)


let debugCoordinateBound = GMSCoordinateBounds(
        coordinate: CLLocationCoordinate2D(latitude: debugNELat, longitude: debugNELng),
        coordinate: CLLocationCoordinate2D(latitude: debugSWLat, longitude: debugSWLng))
/* DEBUG CODE END */


class PlanComposerViewController: FormViewController {
    var plan: Plan?

    override func viewDidLoad() {
        super.viewDidLoad()

        form
        +++ Section("Name")
            <<< GooglePlacesTableRow() {
                $0.tag = "EstablishmentName"
                $0.placeFilter?.type = debugNamePlaceFilterType
                $0.placeBounds = debugCoordinateBound
            }
            .onChange(updateFormUsingGooglePlacesTableRow)

        +++ Section("Location")
            <<< GooglePlacesTableRow() {
                $0.tag = "EstablishmentLocation"
                $0.placeFilter?.type = debugLocationPlaceFilterType
                $0.placeBounds = debugCoordinateBound
            }
            .onChange { row in
                let dictionary = self.form.values()

                if let place = dictionary["EstablishmentLocation"] as? GooglePlace {
                    switch place {
                    case let GooglePlace.userInput(value: value):
                        debugLog("userInput", value)
                    case let GooglePlace.prediction(prediction: prediction):
                        debugLog(nil, nil)
                        debugLog("GooglePlace.prediction", nil)
                        debugLog("  attributedFullText",
                                prediction.attributedFullText.string)
                        debugLog("  attributedPrimaryText",
                                prediction.attributedPrimaryText.string)
                        debugLog("  attributedSecondaryText",
                                prediction.attributedSecondaryText?.string)
                        debugLog("  placeID", prediction.placeID)
                        debugLog("  types", prediction.types)
                        debugLog(nil, nil)
                    }
                }
            }

        +++ Section("Phone Number")
            <<< PhoneRow() {
                $0.tag = "EstablishmentContact"
            }

        +++ Section("Date")
            <<< DateRow() {
                $0.tag = "StartDate"

                var calendar = Calendar(identifier: .gregorian)
                calendar.timeZone = TimeZone(abbreviation: "UTC")!

                $0.value = calendar.date(bySettingHour: 12, minute: 0,
                        second: 0, of: Date()) ?? Date()
            }

        let nameRow = self.form.rowBy(tag: "EstablishmentName")
                as! GooglePlacesTableRow
        nameRow.cell.textField.becomeFirstResponder()

        /* DEBUG CODE BEG: Get geocode info of a place */
        GooglePlacesAPIController.shared.getGeocode(address: "Salt Lake City") {
                (destinations: [GooglePlaceDestination]?, error: Error?) in
                    if destinations != nil {
                        for destination in destinations! {
                            debugLog("Place ID", "\(destination.address)")
                            debugLog("Lat, Lng",
                                    "\(destination.geometryLocationLat)" +
                                    ", \(destination.geometryLocationLng)")
                            debugLog("NE Lat, Lng",
                                    "\(destination.geometryViewportNELat)" +
                                    ", \(destination.geometryViewportNELng)")
                            debugLog("SW Lat, Lng",
                                    "\(destination.geometryViewportSWLat)" +
                                    ", \(destination.geometryViewportSWLng)")
                            print("let (debugNELat, debugNELng) = (\(destination.geometryViewportNELat), \(destination.geometryViewportNELng))")
                            print("let (debugSWLat, debugSWLng) = (\(destination.geometryViewportSWLat), \(destination.geometryViewportSWLng))")
                        }
                    } else if let error = error {
                        print("ERROR: \(error.localizedDescription)")
                    }
                }
        /* DEBUG CODE END */
    }

    func updateFormUsingGooglePlacesTableRow(row: GooglePlacesTableRow) {
        let dictionary = form.values()

        if let place = dictionary["EstablishmentName"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                debugLog("userInput", value)
            case let GooglePlace.prediction(prediction: prediction):
                debugLog(nil, nil)
                debugLog("GooglePlace.prediction", nil)
                debugLog("  attributedFullText",
                        prediction.attributedFullText.string)
                debugLog("  attributedPrimaryText",
                        prediction.attributedPrimaryText.string)
                debugLog("  attributedSecondaryText",
                        prediction.attributedSecondaryText?.string)
                debugLog("  placeID", prediction.placeID)
                debugLog("  types", prediction.types)
                debugLog(nil, nil)

                row.value = GooglePlace(
                        string: prediction.attributedPrimaryText.string)

                if let placeID = prediction.placeID {
                    GooglePlacesAPIController.shared.getPlaceDetail(
                            placeId: placeID) {
                            (place: GooglePlacePlace?, error: Error?) in
                                if let place = place {
                                    debugLog(nil, nil)
                                    debugLog("Place detail", nil)
                                    debugLog("  ID", place.placeId)
                                    debugLog("  Name", place.name)
                                    debugLog("  Address", place.address)
                                    debugLog("  Phone #", place.phoneNo)
                                    debugLog("  Street #", place.streetNo)
                                    debugLog("  Street", place.streetName)
                                    debugLog("  City", place.city)
                                    debugLog("  State", place.state)
                                    debugLog("  ZIP code", place.zipCode)
                                    debugLog("  Country", place.country)
                                    debugLog(nil, nil)

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
                                } else if let error = error {
                                    print("ERROR: \(error.localizedDescription)")
                                }
                            }
                }
            }
        }
    }

    @IBAction func cancelChanges(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveChanges(_ sender: Any) {
        let dictionary = form.values()
        let dbPlan = PFObject(className: "Plan")

        if let place = dictionary["EstablishmentName"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                dbPlan["estabName"] = value
            case let GooglePlace.prediction(prediction: prediction):
                dbPlan["estabName"] = prediction.attributedPrimaryText.string
            }
        }

        if let place = dictionary["EstablishmentLocation"] as? GooglePlace {
            switch place {
            case let GooglePlace.userInput(value: value):
                dbPlan["estabLocation"] = value
            case let GooglePlace.prediction(prediction: prediction):
                dbPlan["estabLocation"] = prediction.attributedFullText.string
            }
        }

        if let phoneNo = dictionary["EstablishmentContact"] as? String {
            dbPlan["estabContact"] = phoneNo
        }

        if let date = dictionary["StartDate"] as? Date {
            dbPlan["startDate"] = date
        }

        dbPlan["planType"] = "natural_feature"
        dbPlan["planStage"] = "proposal"
        dbPlan["createdBy"] = PFUser.current()

        debugLog(nil, nil)
        debugLog("Plan to be saved", nil)
        debugLog("  estabName", dbPlan["estabName"])
        debugLog("  estabLocation", dbPlan["estabLocation"])
        debugLog("  estabContact", dbPlan["estabContact"])
        debugLog("  startDate", dbPlan["startDate"])
        debugLog(nil, nil)

        dbPlan.saveInBackground { (success, error) in
            if success {
                print("Plan is successfully saved!")
            } else if error != nil {
                print("ERROR: \(error!.localizedDescription)")
            }
        }

        dismiss(animated: true, completion: nil)
    }
}
