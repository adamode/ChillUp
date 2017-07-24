//
//  RegisterVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class RegisterVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var choosePhotoBtn: UIButton! {
        
        didSet {
            
            choosePhotoBtn.addTarget(self, action: #selector(choosePhotoBtnTapped(_:)), for: .touchUpInside)
            choosePhotoBtn.layer.cornerRadius = 15
            choosePhotoBtn.layer.borderWidth = 1
            choosePhotoBtn.layer.borderColor = UIColor.black.cgColor
        }
    }
    @IBOutlet weak var signUpBtn: UIButton! {
        
        didSet {
            
            signUpBtn.addTarget(self, action: #selector(signUpBtnTapped(_:)), for: .touchUpInside)
            signUpBtn.layer.cornerRadius = 15
            signUpBtn.layer.borderWidth = 1
            signUpBtn.layer.borderColor = UIColor.black.cgColor
        }
    }
    @IBOutlet weak var confirmPasswordTextField: UITextField! {
        
        didSet {
            
            confirmPasswordTextField.placeholder = "Confirm password"
            confirmPasswordTextField.delegate = self
            confirmPasswordTextField.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var passwordTextField: UITextField! {
        
        didSet {
            
            passwordTextField.placeholder = "Insert password"
            passwordTextField.delegate = self
            passwordTextField.isSecureTextEntry = true
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        
        didSet {
            
            emailTextField.placeholder = "Insert email"
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var nameTextField: UITextField! {
        
        didSet {
            
            nameTextField.placeholder = "Insert name"
            nameTextField.delegate = self
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var isImageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        setupSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y == 0 {
                
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if self.view.frame.origin.y != 0 {
                
                self.view.frame.origin.y += keyboardSize.height
            }
        }
        
    }
    
    
    func imageTapped(sender: UITapGestureRecognizer) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        let alertController = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickerController.sourceType = .camera
                self.present(pickerController, animated: true, completion: nil)
            } else {
                let alertVC = UIAlertController(title: "No Camera",message: "Sorry, this device has no camera",preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK",style:.default,handler: nil)
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true,completion: nil)
                return
            }
        }
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(camera)
        alertController.addAction(photoLibrary)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            
            emailTextField.becomeFirstResponder()
            
        } else if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            confirmPasswordTextField.becomeFirstResponder()
        } else if textField == confirmPasswordTextField {
            confirmPasswordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func choosePhotoBtnTapped(_ sender : Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    func signUpBtnTapped(_ sender : Any) {
        
        self.activityIndicator.startAnimating()
        
        guard
            let name = nameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            let confirmPassword = confirmPasswordTextField.text
            else {
                
                return
        }
        
        if name == "" {
            
            self.warningAlert(warningMessage: "Please enter your username")
            
        } else if password == "" || password.characters.count < 6 {
            
            self.warningAlert(warningMessage: "Please enter your password")
            
        } else if email == "" {
            
            self.warningAlert(warningMessage: "Please enter your email")
            
        } else if password != confirmPassword {
            
            self.warningAlert(warningMessage: "Password and confirmed password does not match")
            
        } else if isImageSelected == false {
            
            self.warningAlert(warningMessage: "Please select profile picture")
            
        } else {
            
            self.activityIndicator.startAnimating()

            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                
                if let validError = error {
                    
                    print(validError.localizedDescription)
                    
                    self.warningAlert(warningMessage: "Please enter another email address")
                    
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                let storageRef = Storage.storage().reference()
                
                let metadata = StorageMetadata()
                
                metadata.contentType = "image/jpg"
                
                let data = UIImageJPEGRepresentation(self.imageView.image!, 0.8)
                
                storageRef.child("\(uid).jpg").putData(data!, metadata: metadata, completion: { (newMeta, error) in
                    
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
                        
                        let param : [String : Any] = ["name": name,
                                                      "email": email,
                                                      "profileImageURL": imageURL]
                        
                        let ref = Database.database().reference().child("users")
                        
                        ref.child(uid).setValue(param)
                    }
                    
                })
                
                self.activityIndicator.stopAnimating()
                
                print("User sign-up successfully! \(user?.uid ?? "")")
                print("User email address! \(user?.email ?? "")")
                print("Username is \(name)")
                
            })
        }
    }
    
    func setupSpinner(){
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        
        view.addSubview(activityIndicator)
    }
    
    func warningAlert(warningMessage: String){
        let alertController = UIAlertController(title: "Error", message: warningMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(ok)
        
        present(alertController, animated: true, completion: nil)
        self.activityIndicator.stopAnimating()
        
    }
    
}

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.isImageSelected = false
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        self.imageView.image = selectedImage
        
        self.isImageSelected = true
        
        dismiss(animated: true, completion: nil)
    }
    
}
