//
//  ProfileVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileVC: UIViewController {

    @IBOutlet weak var logOutBtn: UIButton! {
        
        didSet {
            
            logOutBtn.addTarget(self, action: #selector(logOutBtnPressed(_:)), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func logOutBtnPressed(_ sender: Any) {
        
        let firebaseAuth = Auth.auth()
        
        let loginManager = FBSDKLoginManager()
        
        do {
            
            try firebaseAuth.signOut()
            loginManager.logOut()
            
            print ("Logged out successfully!")
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
            return
        }

    }

}
