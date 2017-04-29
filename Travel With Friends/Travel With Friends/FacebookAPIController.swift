//
//  FacebookAPIController.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/27/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation
import FacebookCore
import FacebookLogin
import Unbox



class FacebookAPIController {
    static let shared = FacebookAPIController()
    
    let accessToken = AccessToken.current
    
    
    
    
    
    func getUsersFriendsWhoHaveApp(completion: @escaping ([FacebookUser]?, Error?) -> ()) {
        let connection = GraphRequestConnection()
        connection.add(UserFriendsRequest()) { response, result in
            switch result {
            case .success(let response):
                print("Custom Graph Request Succeeded: \(response)")
                completion(response.facebookFriendsWithApp, nil)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
                
                completion(nil, error)
            }
        }
        connection.start()
    }
    
    
    func getUserInfo(completion: @escaping (FacebookUser?, Error?) -> ()) {
        let connection = GraphRequestConnection()
        connection.add(UserInfoRequest()) { response, result in
            switch result {
            case .success(let response):
                print("Custom Graph Request Succeeded: \(response)")
                completion(response.user, nil)
            case .failed(let error):
                print("Custom Graph Request Failed: \(error)")
                completion(nil, error)
            }
        }
        connection.start()
    }

    
    
}

struct UserFriendsRequest: GraphRequestProtocol {
    
    struct Response: GraphResponseProtocol {
        var facebookFriendsWithApp : [FacebookUser] = []
        var errorParsing = false
        
        init(rawResponse: Any?) {
            if let jsonResult = rawResponse as? Dictionary<String, Any> {
                // do whatever with jsonResult
                do {
                    facebookFriendsWithApp = try unbox(dictionaries: jsonResult["data"] as! [UnboxableDictionary])
                } catch  {
                    print("Error trying to get fb friends")
                    errorParsing = true
                }
            }else{
                print("Error trying to get fb friends")
                errorParsing = true
            }
        }
    }
    
    var graphPath = "me/friends"
    var parameters: [String : Any]? = ["fields": "id, name, picture.type(large)"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}


struct UserInfoRequest: GraphRequestProtocol {
    
    struct Response: GraphResponseProtocol {
        var user : FacebookUser?
        var errorParsing = false
        
        init(rawResponse: Any?) {
            if let jsonResult = rawResponse as? Dictionary<String, Any> {
                do {
                    user = try unbox(dictionary: jsonResult)
                        
                } catch  {
                    print("Error trying to get fb friends")
                    errorParsing = true
                }
            }else{
                print("Error trying to get fb friends")
                errorParsing = true
            }
        }
    }
    
    var graphPath = "me"
    var parameters: [String : Any]? = ["fields": "id, name, picture.type(large)"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}



