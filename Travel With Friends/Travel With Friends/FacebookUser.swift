//
//  FacebookUser.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/28/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import Foundation
import Unbox


struct FacebookUser : Unboxable {
    
    let id : Int
    let name : String
    let picture : Picture?
    let email : String
    
    init(unboxer: Unboxer) throws {
        self.id = try unboxer.unbox(key: "id")
        self.name = try unboxer.unbox(key: "name")
        self.picture = unboxer.unbox(key: "picture")
        self.email = try unboxer.unbox(key: "email")
    }
}

struct Picture : Unboxable {
    
    let pictureData : PictureData?
    
    init(unboxer: Unboxer) throws {
        self.pictureData = unboxer.unbox(key: "data")
    }
    
    struct PictureData : Unboxable {
        let isSilhouette : Int?
        let url : URL?
        init(unboxer: Unboxer) throws {
            self.isSilhouette = unboxer.unbox(key: "is_silhouette")
            let profileUrl : String?  = unboxer.unbox(key: "url")
            if let profileUrl = profileUrl {
                self.url = URL(string: profileUrl)
            }else{
                self.url = nil
            }
        }
    }
}


