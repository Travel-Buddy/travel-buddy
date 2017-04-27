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
