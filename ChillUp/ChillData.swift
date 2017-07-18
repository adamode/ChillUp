//
//  ChillData.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import Foundation
import Firebase

class ChillData {
    
    var pid: String?
    var name: String?
    var userID: String?
    var timeStamp: Date?
    var imageURL: URL?
    var eventName: String?
    var eventDescription: String?
    var eventDateandTime: String?
    var eventCategory: String?
    
    init?(snapshot: DataSnapshot) {
        
        self.pid = snapshot.key
        
        guard
        let dictionary = snapshot.value as? [String:Any],
        let validUser = dictionary["userID"] as? String,
        let validTimestamp = dictionary["timeStamp"] as? Double,
        let validName = dictionary["userName"] as? String,
        let validEventCategory = dictionary["eventCategory"] as? String,
        let validEventDateandTime = dictionary["eventDateandTime"] as? String,
        let validEventDescription = dictionary["eventDescription"] as? String,
        let validEventName = dictionary["eventName"] as? String
            else { return nil }
        

        self.name = validName
        self.userID = validUser
        self.timeStamp = Date(timeIntervalSince1970: validTimestamp)
        self.eventName = validEventName
        self.eventCategory = validEventCategory
        self.eventDescription = validEventDescription
        self.eventDateandTime = validEventDateandTime
        
        if let validImageURL = dictionary["imageURL"] as? String {
            
            self.imageURL = URL(string: validImageURL)
        }
        
    }
    
}
