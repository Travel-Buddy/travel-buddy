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
    
}
