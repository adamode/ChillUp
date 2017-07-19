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
import SDWebImage

class ProfileVC: UIViewController {

    @IBOutlet weak var logOutBtn: UIButton! {
        
        didSet {
            
            logOutBtn.addTarget(self, action: #selector(logOutBtnPressed(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var settingBtn: UIButton! {
        
        didSet {
            
            settingBtn.addTarget(self, action: #selector(settingBtnPressed(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        
        didSet {
            
            segmentedControl.addTarget(self, action: #selector(segmentedControlPressed(_:)), for: .valueChanged)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var profileImgURL: String = ""
    var currentUserID: String?
    var eventCreated: [ChillData] = []
    var eventRSVP: [ChillData] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserDetails()
//        getEventCreated()
        
    }
    // the method to hid nav bar 
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func segmentedControlPressed(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex {
            
        case 0:
            getUserDetails()
            self.tableView.reloadData()

        case 1:
            getRSVP()
            self.tableView.reloadData()
        default:
            break;
        }
    }
    
    func getUserDetails() {
        
        let ref = Database.database().reference()
            
            if let user = Auth.auth().currentUser?.uid {
                
                ref.child("users").child(user).observe(.value, with: { (snapshot) in

                    if let userDetails = UserProfile(snapshot: snapshot) {
                    
                    let username = userDetails.name
                    let email = userDetails.email
                    
                    
                    if let profileURL = userDetails.profileImage {
                        
                        self.profileImage.sd_setImage(with: profileURL as URL)
                    }
                        
                    self.loginLabel.text = userDetails.providerName
                    
                    if let FBid = userDetails.fbID {
                    
                     let FBurl = NSURL(string: "https://graph.facebook.com/\(FBid)/picture?type=large&return_ssl_resources=1")
                        
                        self.profileImage.sd_setImage(with: FBurl! as URL)
                    }
                    
                    self.nameLabel.text = username
                    
                    self.emailLabel.text = email
                                    
                    self.eventCreated = []
                    
                    guard let postDictionary = userDetails.post
                        
                        else { return }
                        
                        self.eventCreated = []
                    
                    for (key,_) in postDictionary {
                        
                        self.getPost(key)
                    }
                    
                }
                    
            }){ (error) in
                    
                    print(error.localizedDescription)
                    
                    return
            }
        }
    }
    
    func getPost(_ postID: String) {
        
        let ref = Database.database().reference()
        
        ref.child("posts").child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let data = ChillData(snapshot: snapshot) {
                
                self.eventCreated.append(data)
            }

            self.tableView.reloadData()
        })
        
    }
    
    func getRSVPEvent(_ postID: String) {
        
        let ref = Database.database().reference()
        
        ref.child("posts").child(postID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let data = ChillData(snapshot: snapshot) {
                
                self.eventRSVP.append(data)
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    func getRSVP() {
        
        let ref = Database.database().reference()
        
        if let user = Auth.auth().currentUser?.uid {
            
            ref.child("users").child(user).observe(.value, with: { (snapshot) in
                
                if let userDetails = UserProfile(snapshot: snapshot) {
                    
                    guard let postDictionary = userDetails.eventJoined
                        
                        else { return }
                    
                    self.eventRSVP = []
                    
                    for (key,_) in postDictionary {
                        
                        self.getRSVPEvent(key)
                    }
                }
                
            })
            
        }
    }
    
    func settingBtnPressed(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "EditVC")
        self.present(mainVC, animated: true, completion: nil)

    }
    
    func logOutBtnPressed(_ sender: Any) {
    
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    let signOut = UIAlertAction(title: "Log Out", style: .destructive) { (action) in
        let firebaseAuth = Auth.auth()
        let loginManager = FBSDKLoginManager() //FB system logout
        
        do {
            try firebaseAuth.signOut()
            loginManager.logOut()
            
            print ("Logged out successfully!")
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
            return
        }
    }
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(signOut)
    alertController.addAction(cancel)
    
    present(alertController, animated: true, completion: nil)
        
    }
}


extension ProfileVC: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if segmentedControl.selectedSegmentIndex == 0 {

        return eventCreated.count
            
        } else {
            
            return eventRSVP.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ProfileCell
        
        if segmentedControl.selectedSegmentIndex == 0 {

            let data = eventCreated[indexPath.row]
            
            cell.profileCellTitle.text = data.eventName
            cell.profileCellDescription.text = data.eventDescription
            cell.profileCellImage.sd_setImage(with: data.imageURL)
            
            return cell
            
        } else {
            
            let data = eventRSVP[indexPath.row]
            
            cell.profileCellTitle.text = data.eventName
            cell.profileCellDescription.text = data.eventDescription
            cell.profileCellImage.sd_setImage(with: data.imageURL)
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
        
        let chill = eventCreated[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let selectedVC = storyboard.instantiateViewController(withIdentifier: "SelectedCellVC") as! SelectedCellVC
        
        selectedVC.getCell = chill
        
        self.navigationController?.pushViewController(selectedVC, animated: true)
            
        } else {
            
            let chill = eventRSVP[indexPath.row]
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let selectedVC = storyboard.instantiateViewController(withIdentifier: "SelectedCellVC") as! SelectedCellVC
            
            selectedVC.getCell = chill
            
            self.navigationController?.pushViewController(selectedVC, animated: true)
            
        }
    }

}


