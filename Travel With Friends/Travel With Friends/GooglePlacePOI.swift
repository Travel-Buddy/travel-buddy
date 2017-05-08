//
//  GooglePlacePOI.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/27/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation
import Unbox


class GooglePlacePOI : Unboxable {
    var name : String = ""
    var voteCount: Int = 0
    var voteFor = false
    
    
    init(n: String) {
        name = n
    }
    
    
    required init(unboxer: Unboxer) throws {
        self.name = try unboxer.unbox(key: "name")
        
    }
    
    //need to change to dictionary of users that have voted
    // var voted = [UserID : true] etc
    
}

class GooglePlaceDestination: Unboxable {
    let address: String
    let geometryLocationLat: Double
    let geometryLocationLng: Double
    let geometryViewportNELat: Double
    let geometryViewportNELng: Double
    let geometryViewportSWLat: Double
    let geometryViewportSWLng: Double
    let placeId: String
    /*
    let types: [String]?
    */

    required init(unboxer: Unboxer) throws {
        address = try unboxer.unbox(key: "formatted_address")
        geometryLocationLat = try unboxer.unbox(
                keyPath: "geometry.location.lat")
        geometryLocationLng = try unboxer.unbox(
                keyPath: "geometry.location.lng")
        geometryViewportNELat = try unboxer.unbox(
                keyPath: "geometry.viewport.northeast.lat")
        geometryViewportNELng = try unboxer.unbox(
                keyPath: "geometry.viewport.northeast.lng")
        geometryViewportSWLat = try unboxer.unbox(
                keyPath: "geometry.viewport.southwest.lat")
        geometryViewportSWLng = try unboxer.unbox(
                keyPath: "geometry.viewport.southwest.lng")
        placeId = try unboxer.unbox(key: "place_id")
        /*
        types = try unboxer.unbox(key: "types")
        */
    }
}

class GooglePlacePlace: Unboxable {
    var placeId: String
    var name: String?
    var address: String?
    var phoneNo: String?
    var streetNo: String?
    var streetName: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?

    required init(unboxer: Unboxer) throws {
        placeId = try unboxer.unbox(key: "place_id")
        name = try? unboxer.unbox(keyPath: "name")
        address = try? unboxer.unbox(keyPath: "formatted_address")
        phoneNo = try? unboxer.unbox(keyPath: "international_phone_number")

        let addressComponents: [[String : Any]] = try unboxer.unbox(
                key: "address_components")
        for addressComponent in addressComponents {
            let types = addressComponent["types"] as! [String]
            for type in types {
                if type == "street_number" {
                    streetNo = addressComponent["short_name"] as? String
                    break
                } else if type == "street_address" || type == "route" {
                    streetName = addressComponent["short_name"] as? String
                    break
                } else if type == "locality" {
                    city = addressComponent["short_name"] as? String
                    break
                } else if type == "administrative_area_level_1" {
                    state = addressComponent["short_name"] as? String
                    break
                } else if type == "postal_code" {
                    zipCode = addressComponent["short_name"] as? String
                    break
                } else if type == "country" {
                    country = addressComponent["short_name"] as? String
                    break
                }
            }
        }
    }
}
