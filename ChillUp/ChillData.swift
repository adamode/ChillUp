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
    var eventDate: String?
    var eventTime: String?
    var eventCategory: String?
    var placemarkLocation: String?
    var lat: Double?
    var long: Double?
    
    init?(snapshot: DataSnapshot) {
        
        self.pid = snapshot.key
        
        guard
        let dictionary = snapshot.value as? [String:Any],
        let validUser = dictionary["userID"] as? String,
        let validTimestamp = dictionary["timeStamp"] as? Double,
        let validName = dictionary["userName"] as? String,
        let validEventCategory = dictionary["eventCategory"] as? String,
        let validEventDate = dictionary["eventDate"] as? String,
        let validEventTime = dictionary["eventTime"] as? String,
        let validEventDescription = dictionary["eventDescription"] as? String,
        let validEventName = dictionary["eventName"] as? String
            else { return nil }
        

        name = validName
        userID = validUser
        timeStamp = Date(timeIntervalSince1970: validTimestamp)
        eventName = validEventName
        eventCategory = validEventCategory
        eventDescription = validEventDescription
        eventDate = validEventDate
        eventTime = validEventTime
        
        if let validImageURL = dictionary["imageURL"] as? String {
            
            self.imageURL = URL(string: validImageURL)
        }
        
        if let validPlacemark = dictionary["placeMarkLocation"] as? String {
            
            placemarkLocation = validPlacemark
        }
        
        if let validLat = dictionary["lat"] as? Double {
            
            lat = validLat
        }
        
        if let validLong = dictionary["long"] as? Double {
            
            long = validLong

        }
        
    }
    
}
