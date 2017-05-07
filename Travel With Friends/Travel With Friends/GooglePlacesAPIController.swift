//
//  GooglePlacesAPIController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/27/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation
import Alamofire
import UnboxedAlamofire
import GooglePlaces


class GooglePlacesAPIController {
    static let shared = GooglePlacesAPIController()

    static private let APIKey =
            "AIzaSyDySsW0u9ysZ-DrlmgRw_bXe6yKoWG1plo"

    private let placesKeyForSearch = "AIzaSyDQM3QbE5hO8_z4biLKn973lDCWGELrojo"
    private let placesPOIAttractionsTextSearchURL = "https://maps.googleapis.com/maps/api/place/textsearch/json?"
    
    func getPOIFrom(locationString: String?, completion: @escaping ([GooglePlacePOI]?, Error?) -> ()){
        
        let searchString = locationString! + " point of interest"
        

        let params: [String : Any] = ["query" : searchString, "language" : "en", "key" : placesKeyForSearch]
        
        Alamofire.request(placesPOIAttractionsTextSearchURL, method: .get, parameters: params, encoding: URLEncoding.queryString)
            .responseArray(queue: DispatchQueue.main, keyPath: "results", options: JSONSerialization.ReadingOptions.allowFragments) { (response: DataResponse<[GooglePlacePOI]>) in
                switch response.result {
                case .success(let value):
                    let places = value
                    completion(places, nil)
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil, error)
                }
        }
    }


    func getGeocode(address: String,
            completion: @escaping ([GooglePlaceDestination]?, Error?) -> Void) {
        let params: [String : Any] = [
            "address" : address,
            "key" : GooglePlacesAPIController.APIKey
        ]

        Alamofire.request("https://maps.googleapis.com/maps/api/geocode/json?",
                method: .get, parameters: params,
                encoding: URLEncoding.queryString).responseArray(
                queue: DispatchQueue.main, keyPath: "results",
                options: JSONSerialization.ReadingOptions.allowFragments) {
                (response: DataResponse<[GooglePlaceDestination]>) in
                    switch response.result {
                    case .success(let destinations):
                        completion(destinations, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
    }

    /* DEBUG: Not working because GooglePlacePlace has been modified
    func getPlaceAutocomplete(input: String, lat: Double, lng: Double,
            types: String,
            completion: @escaping ([GooglePlacePlace]?, Error?) -> Void) {
        let params: [String : Any] = [
            "input" : input,
            "location": "\(lat),\(lng)",
            "types": types,
            "key" : GooglePlacesAPIController.APIKey
        ]

        Alamofire.request(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?",
                method: .get, parameters: params,
                encoding: URLEncoding.queryString).responseArray(
                queue: DispatchQueue.main, keyPath: "predictions",
                options: JSONSerialization.ReadingOptions.allowFragments) {
                (response: DataResponse<[GooglePlacePlace]>) in
                    switch response.result {
                    case .success(let places):
                        completion(places, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
    }
    */

    func getPlaceDetail(placeId: String,
            completion: @escaping (GooglePlacePlace?, Error?) -> Void) {
        let params: [String : Any] = [
            "placeid" : placeId,
            "key" : GooglePlacesAPIController.APIKey
        ]

        Alamofire.request(
                "https://maps.googleapis.com/maps/api/place/details/json?",
                method: .get, parameters: params,
                encoding: URLEncoding.queryString).responseObject(
                queue: DispatchQueue.main, keyPath: "result",
                options: JSONSerialization.ReadingOptions.allowFragments) {
                (response: DataResponse<GooglePlacePlace>) in
                    switch response.result {
                    case .success(let place):
                        completion(place, nil)
                    case .failure(let error):
                        completion(nil, error)
                    }
                }
    }
}
