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

class CreateVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var chillUpName: UITextField! {
        
        didSet {
            
            chillUpName.delegate = self
        }
    }
    @IBOutlet weak var chillUpDescription: UITextField! {
        
        didSet {
            
            chillUpDescription.delegate = self
        }
    }
    
    @IBOutlet weak var chillUpDate: UITextField! {
        
        didSet {
            
            chillUpDate.delegate = self
        }
    }
    @IBOutlet weak var chillUpCategory: UITextField! {
        
        didSet {
            
            chillUpCategory.delegate = self
            
        }
    }
    
    @IBOutlet weak var chillTime: UITextField! {
        
        didSet {
            
            chillTime.delegate = self
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        
        didSet {
            
            mapView.delegate = self
        }
    }
    
    @IBOutlet weak var submitBtn: UIButton! {
        
        didSet {
            
            submitBtn.addTarget(self, action: #selector(submitBtnPressed(_:)), for: .touchUpInside)
            submitBtn.layer.cornerRadius = 15
            submitBtn.layer.borderWidth = 1
            submitBtn.layer.borderColor = UIColor.black.cgColor
        }
    }
    @IBOutlet weak var uploadPhotoBtn: UIButton! {
        
        didSet {
            
            uploadPhotoBtn.addTarget(self, action: #selector(uploadPhotoBtnTapped(_:)), for: .touchUpInside)
            uploadPhotoBtn.layer.cornerRadius = 15
            uploadPhotoBtn.layer.borderWidth = 1
            uploadPhotoBtn.layer.borderColor = UIColor.black.cgColor
        }
    }
    
    @IBOutlet weak var chillEndTime: UITextField! {
        
        didSet {
            
            chillEndTime.delegate = self
        }
    }
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var getUsername : String = ""
    var isImageSelected = false
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    let locationManager = CLLocationManager()
    let pinView = MKPointAnnotation()
    var selectedAnnotation: MKPointAnnotation?
    var placemarkLocation: String?
    var getLat: Double?
    var getLong: Double?
    let datePicker = UIDatePicker()
    let timePicker = UIDatePicker()
    let endTimePicker = UIDatePicker()
    let categoryPicker = UIPickerView()
    var selectedRow = 0
    let categoryArray = ["Outdoors & Adventure","Tech","Family","Health & Wellness","Sport & Fitness","Learning","Photography","Food & Drink","Writing","Language & Culture","Music","Movements","Film","Games","Beliefs", "Arts","Normal Gathering","Book Clubs","Pets","Dance","Career & Business","Social","Fashion & Beauty","Hobbies"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsernameFromFirebase()
        setupSpinner()
        
        activityIndicator.color = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        
        determineCurrentLocation()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        chooseCategory()
        showDatePicker()
        showTimePicker()
        showEndTimePicker()
        
        scrollView.keyboardDismissMode = .onDrag
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
    }
    
    // Date Picker
    
    func showDatePicker() {
        
        datePicker.datePickerMode = .date
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneDatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        chillUpDate.inputAccessoryView = toolbar
        chillUpDate.inputView = datePicker
    }
    
    func doneDatePicker() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        chillUpDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    func cancelDatePicker() {
        
        self.view.endEditing(true)
    }
    // Time Picker
    
    func showTimePicker() {
        
        timePicker.datePickerMode = .time
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelTimePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        chillTime.inputAccessoryView = toolbar
        chillTime.inputView = timePicker
    }
    
    func doneTimePicker() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = " hh:mm a"
        chillTime.text = formatter.string(from: timePicker.date)
        self.view.endEditing(true)
    }
    
    func cancelTimePicker() {
        
        self.view.endEditing(true)
    }
    
    // End Time Picker
    
    func showEndTimePicker() {
        
        endTimePicker.datePickerMode = .time
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(doneEndTimePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelEndTimePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        chillEndTime.inputAccessoryView = toolbar
        chillEndTime.inputView = endTimePicker
    }
    
    func doneEndTimePicker() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = " hh:mm a"
        chillEndTime.text = formatter.string(from: endTimePicker.date)
        self.view.endEditing(true)
    }
    
    func cancelEndTimePicker() {
        
        self.view.endEditing(true)
    }
    
    // Category Picker
    
    
    func chooseCategory() {
        
        let pickerView = categoryPicker
        pickerView.backgroundColor = .white
        pickerView.showsSelectionIndicator = true
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(cancelPicker))
        
        toolBar.setItems([doneButton, spaceButton, cancelButton], animated: false)
        
        chillUpCategory.inputView = pickerView
        chillUpCategory.inputAccessoryView = toolBar
    }
    
    func donePicker() {
        
        self.chillUpCategory.text = categoryArray[selectedRow]
        chillUpCategory.resignFirstResponder()
    }
    
    func cancelPicker() {
        
        chillUpCategory.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        chillUpDescription.resignFirstResponder()
        chillTime.resignFirstResponder()
        chillUpDate.resignFirstResponder()
        chillUpCategory.resignFirstResponder()
        chillUpName.resignFirstResponder()
        
        return true
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
            let eventDate = chillUpDate.text,
            let eventTime = chillTime.text,
            let eventCategory = chillUpCategory.text,
            let eventEndTime = chillEndTime.text
            
            else { return }
        
        let now = Date()
        let param : [String:Any] = ["userID" : uid,
                                    "userName" : self.getUsername,
                                    "timeStamp": now.timeIntervalSince1970,
                                    "imageURL": eventPic,
                                    "eventName": eventName,
                                    "eventDescription": eventDesc,
                                    "eventDate": eventDate,
                                    "eventTime": eventTime,
                                    "eventEndTime": eventEndTime,
                                    "eventCategory": eventCategory,
                                    "placeMarkLocation": placemarkLocation ?? "",
                                    "lat": getLat ?? "",
                                    "long": getLong ?? "" ]
        
        let ref = Database.database().reference().child("posts").childByAutoId()
        ref.setValue(param)
        
        let currentPID = ref.key
        print(currentPID)
        
        let updateUserPID = Database.database().reference().child("users").child(uid).child("post")
        updateUserPID.updateChildValues([currentPID: true])
        
    }
    
    func submitBtnPressed(_ sender: Any) {
        
        self.activityIndicator.startAnimating()
        
        self.submitBtn.isEnabled = false
        
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
                    self.submitBtn.isEnabled = true
                    
                    self.chillUpName.text = nil
                    self.photoImageView.image = nil
                    self.chillUpDescription.text = nil
                    self.chillUpDate.text = nil
                    self.chillTime.text = nil
                    self.chillUpCategory.text = nil
                    self.mapView.removeAnnotation(self.selectedAnnotation!)
                    
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
    
    func loadPlaceMark(location : CLLocation) {
        
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            
            if let validError = error{
                
                print("GeoCode Error: \(validError.localizedDescription)")
            }
            
            if let placemark = placemarks?.first {
                
                var text : [String] = []
                
                for item in [placemark.name, placemark.thoroughfare, placemark.locality] {
                    
                    if let name = item { text.append(name) }
                }
                
                let finalText = text.joined(separator: ", ")
                
                self.placemarkLocation = finalText
                
                if let displayTextOnPin = self.placemarkLocation {
                    
                    self.selectedAnnotation?.title = "\(displayTextOnPin)"
                }
            }
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
            
            let coordinates: CLLocation = CLLocation(latitude: lat, longitude: long)
            
            self.loadPlaceMark(location: coordinates)
            
            getLat = lat
            getLong = long
            
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

extension CreateVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categoryArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return categoryArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedRow = row
    }
    
}
