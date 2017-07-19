//
//  UserProfile.swift
//  ChillUp
//
//  Created by Mohd Adam on 18/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import Foundation
import Firebase

class UserProfile {
    var uid: String
    var id: String?
    var name: String?
    var profileImage: URL?
    var email: String?
    var loginMethod: String?
    var fbID: String?
    var post: [String:Any]?
    var providerName: String?
    var eventJoined: [String:Any]?
    
    init?(snapshot: DataSnapshot){
        
        self.uid = snapshot.key
        
        guard
            let dictionary = snapshot.value as? [String: Any],
            let validName = dictionary["name"] as? String
            else { return nil }
        
        if let validEmail = dictionary["email"] as? String {
            
            email = validEmail
        }
        
        if let validPost = dictionary["post"] as? [String: Any] {
            
            post = validPost
        }
        
        if let validFBid = dictionary["id"] as? String {
            
            fbID = validFBid

        }
        
        if let validEventJoined = dictionary["eventJoined"] as? [String:Any] {
            
            eventJoined = validEventJoined
        }
        
        if let validImageURL = dictionary["profileImageURL"] as? String {
            
            profileImage = URL(string: validImageURL)
        }
        
        if let provider = Auth.auth().currentUser?.providerData {
            
            for item in provider {
                providerName = item.providerID
            }
        }
        
        name = validName
        
    }
}
