//
//  CreateVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class CreateVC: UIViewController {

    @IBOutlet weak var chillUpName: UITextField!
    @IBOutlet weak var chillUpDescription: UITextField!
    @IBOutlet weak var chillUpDateandTime: UITextField!
    @IBOutlet weak var chillUpCategory: UITextField!
    @IBOutlet weak var mapView: MKMapView! {
        
        didSet {
            
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var submitBtn: UIButton! {
        
        didSet {
            
            submitBtn.addTarget(self, action: #selector(submitBtnPressed(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet weak var uploadPhotoBtn: UIButton! {
        
        didSet {
            
            uploadPhotoBtn.addTarget(self, action: #selector(uploadPhotoBtnTapped(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    var getUsername : String = ""
    var isImageSelected = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let locationManager = CLLocationManager()
    let pinView = MKPointAnnotation()
    var selectedAnnotation: MKPointAnnotation?


    override func viewDidLoad() {
        super.viewDidLoad()

        getUsernameFromFirebase()
        setupSpinner()
        
        activityIndicator.color = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        activityIndicator.backgroundColor = UIColor.gray
        
        determineCurrentLocation()
    }
    
    
    func uploadPhotoBtnTapped(_ sender: Any){
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)

    }
    
    func getUsernameFromFirebase() {
        
        let uid = Auth.auth().currentUser?.uid
        
        Database.database().reference().child("users").child(uid!).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any],
               let name = dictionary["name"] as? String {
                
                self.getUsername = name
            }
        })
    }
    
    func postData(imageURL: String!){
        
        guard
            let uid = Auth.auth().currentUser?.uid,
            let eventName = chillUpName.text,
            let eventPic = imageURL,
            let eventDesc = chillUpDescription.text,
            let eventDateandTime = chillUpDateandTime.text,
            let eventCategory = chillUpCategory.text
        else { return }
        
        let now = Date()
        let param : [String:Any] = ["userID" : uid,
                                    "userName" : self.getUsername,
                                    "timeStamp": now.timeIntervalSince1970,
                                    "imageURL": eventPic,
                                    "eventName": eventName,
                                    "eventDescription": eventDesc,
                                    "eventDateandTime": eventDateandTime,
                                    "eventCategory": eventCategory]
        
        let ref = Database.database().reference().child("posts").childByAutoId()
        ref.setValue(param)
        
        let currentPID = ref.key
        print(currentPID)
        
        let updateUserPID = Database.database().reference().child("users").child(uid).child("post")
        updateUserPID.updateChildValues([currentPID: true])
        
    }
    
    func submitBtnPressed(_ sender: Any) {
        
        self.activityIndicator.startAnimating()

        let storageRef = Storage.storage().reference()
        
        let metadata = StorageMetadata()
        
        metadata.contentType = "image/jpg"
        
        guard let data = UIImageJPEGRepresentation(photoImageView.image!, 0.8) else {
            
            dismiss(animated: true, completion: nil)
            
            return
        }
        
        let uuid = UUID().uuidString
        
        print(uuid)
        
        storageRef.child("\(uuid).jpg").putData(data, metadata: metadata) { (newMeta, error) in
            
            if ( error != nil) {
                
                print(error!)
            } else {
                
                defer {
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                if let foundError = error {
                    
                    print(foundError.localizedDescription)
                    
                    return
                }
                
                guard let imageURL = newMeta?.downloadURLs?.first?.absoluteString else {
                    
                    return
                }
                
                self.postData(imageURL: imageURL)
            }
            
            self.tabBarController?.selectedIndex = 0
            self.activityIndicator.stopAnimating()
            
        }
    }
    
    func setupSpinner() {
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
    }

}

extension CreateVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.isImageSelected = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.photoImageView.image = selectedImage
        
        self.isImageSelected = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func determineCurrentLocation() {
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
}

extension CreateVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKPinAnnotationView()
        annotationView.pinTintColor = UIColor.blue
        annotationView.canShowCallout = true
        annotationView.isDraggable = true
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        
        switch newState {
            
        case .starting:
            print("dragging")
            
        case .ending, .canceling:
            guard
                
            let lat = view.annotation?.coordinate.latitude,
            let long = view.annotation?.coordinate.longitude
                
            else { return }
            
            let coordinates = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            self.selectedAnnotation?.title = "Selected Location"
            
        default:
            
            break
        }
    }
}

extension CreateVC: CLLocationManagerDelegate {
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            
            let region = MKCoordinateRegionMake(locValue, span)
            
            self.locationManager.stopUpdatingLocation()
            
            pinView.coordinate = locValue
            pinView.title = "CURRENT LOCATION"
            
            mapView.addAnnotation(pinView)
            mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        selectedAnnotation = view.annotation as? MKPointAnnotation
    }
}
