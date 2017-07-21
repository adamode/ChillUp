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
    
    @IBOutlet weak var providerImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        
        didSet {
            
            segmentedControl.addTarget(self, action: #selector(segmentedControlPressed(_:)), for: .valueChanged)
            
            self.segmentedControl.layer.cornerRadius = 15.0
            self.segmentedControl.layer.borderWidth = 1
            self.segmentedControl.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.layer.masksToBounds = true
            tableView.layer.borderColor = UIColor( red: 153/255, green: 153/255, blue:0/255, alpha: 1.0 ).cgColor
            tableView.layer.borderWidth = 1.0
        }
    }
    
    var profileImgURL: String = ""
    var currentUserID: String?
    var eventCreated: [ChillData] = []
    var eventRSVP: [ChillData] = []
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserDetails()
        
        setupSpinner()
        
        activityIndicator.color = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        
    }
    
    func setupSpinner() {
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    func segmentedControlPressed(_ sender: Any) {
        
        switch segmentedControl.selectedSegmentIndex {
            
        case 0:
            getUserDetails()
            eventCreated = []
            self.tableView.reloadData()
            
        case 1:
            getRSVP()
            eventRSVP = []
            self.tableView.reloadData()
        default:
            break;
        }
    }
    
    func getUserDetails() {
        
        let ref = Database.database().reference()
        
        if let user = Auth.auth().currentUser?.uid {
            
            ref.child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let userDetails = UserProfile(snapshot: snapshot) {
                    
                    let username = userDetails.name
                    let email = userDetails.email
                    
                    
                    if let profileURL = userDetails.profileImage {
                        
                        self.profileImage.sd_setImage(with: profileURL as URL)
                    }
                    
                    let provider = userDetails.providerName
                    
                    if provider == "password" {
                        
                        self.providerImage.image = UIImage(named: "gmailLogo")
                        
                    } else if provider == "facebook.com" {
                        
                        self.providerImage.image = UIImage(named: "facebookLogo")
                    }
                    
                    if let FBid = userDetails.fbID {
                        
                        if let FBurl = NSURL(string: "https://graph.facebook.com/\(FBid)/picture?type=large&return_ssl_resources=1") {
                            
                            self.profileImage.sd_setImage(with: FBurl as URL)
                            
                        }
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
            
            ref.child("users").child(user).observeSingleEvent(of: .value, with: { (snapshot) in
                
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
        
        activityIndicator.startAnimating()

        
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
        
        activityIndicator.stopAnimating()
        
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


