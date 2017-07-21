//
//  SelectedCellVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 18/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import SDWebImage

class SelectedCellVC: UIViewController {
    
    var getCell: ChillData?
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var participantsCount: UILabel!
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var getUsername: UILabel!
    @IBOutlet weak var getLocation: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView! {
        
        didSet{
            
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var rsvpBtn: UIButton! {
        
        didSet {
            
            rsvpBtn.addTarget(self, action: #selector(rsvpBtnPressed(_:)), for: .touchUpInside)
            rsvpBtn.layer.cornerRadius = 15
            rsvpBtn.layer.borderWidth = 1
            rsvpBtn.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    var isJoining = false
    
    var currentUserID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUsername.text = "Organizer: \(getCell?.name ?? "")"
        self.getLocation.text = getCell?.placemarkLocation
        self.eventTitle.text = "Event: \(getCell?.eventName ?? "")"
        self.descriptionLabel.text = getCell?.eventDescription
        self.timeLabel.text = getCell?.eventTime
        self.endTimeLabel.text = getCell?.eventEndTime
        self.dateLabel.text = getCell?.eventDate
        self.categoryLabel.text = "Category: \(getCell?.eventCategory ?? "")"
        self.eventImageView.sd_setImage(with: getCell?.imageURL)
        
        let yourLocation = MKPointAnnotation()
        yourLocation.coordinate = CLLocationCoordinate2DMake((getCell?.lat)!, (getCell?.long)!)
        yourLocation.title = getCell?.placemarkLocation
        
        mapView.addAnnotation(yourLocation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(yourLocation.coordinate, span)
        mapView.setRegion(region, animated: true)
        
        btnStatus()
        getParticipants()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    func getParticipants() {
        
        let ref = Database.database().reference()
        
        ref.child("posts").child((getCell?.pid)!).child("participants").observe(.value, with: {snapshot in
            
            var count = 0
            count += Int(snapshot.childrenCount)
            self.participantsCount.text = "Participants: \(count)"
            
        })
    }
    
    func btnStatus() {
        
        let ref = Database.database().reference()
        
        ref.child("posts").child((getCell?.pid)!).child("participants").observe(.value, with: { (snapshot) in
            
            if snapshot.hasChild(self.currentUserID!) {
                
                self.rsvpBtn.setTitle("Joined", for: .normal)
                
            } else {
                
                self.rsvpBtn.setTitle("Join", for: .normal)
            }
        })
    }
    
    func rsvpBtnPressed(_ sender: Any) {
        
        if isJoining == false {
            
            if let postID = getCell?.pid {
                
                let ref = Database.database().reference().child("posts").child(postID).child("participants")
                ref.updateChildValues([currentUserID!: true ])
                
                let userRef = Database.database().reference().child("users").child(currentUserID!).child("eventJoined").child(postID)
                userRef.updateChildValues([currentUserID!: true])
            }
            
            isJoining = true
            
        } else {
            
            if let postID = getCell?.pid {
                
                let ref = Database.database().reference().child("posts").child(postID).child("participants")
                ref.child(currentUserID!).removeValue()
                
                let userRef = Database.database().reference().child("users").child(currentUserID!).child("eventJoined").child(postID)
                userRef.child(currentUserID!).removeValue()
            }
            
            isJoining = false
        }
        
    }
}

extension SelectedCellVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = UIColor.blue
        annotationView.canShowCallout = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let centerCoordinate = view.annotation?.coordinate else { return }
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        
        let region = MKCoordinateRegionMake(centerCoordinate, span)
        
        mapView.setRegion(region, animated: true)
    }
}
