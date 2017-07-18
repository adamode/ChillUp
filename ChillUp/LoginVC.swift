//
//  LoginVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FBSDKLoginKit

class LoginVC: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField! {
        
        didSet {
            
            emailTextField.placeholder = "Insert email"
            emailTextField.delegate = self
        }
    }
    
    @IBOutlet weak var passwordTextField: UITextField! {
        
        didSet {
            
            passwordTextField.placeholder = "Insert password"
            passwordTextField.delegate = self
            passwordTextField.isSecureTextEntry = true
            passwordTextField.returnKeyType = .done
        }
    }
    
    @IBOutlet weak var fbLoginBtn: FBSDKLoginButton! {
        
        didSet {
            
            fbLoginBtn.delegate = self
        }
    }
    
    @IBOutlet weak var loginBtn: UIButton! {
        
        didSet {
            
            loginBtn.addTarget(self, action: #selector(loginBtnTapped(_:)), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var registerBtn: UIButton! {
        
        didSet {
        
        registerBtn.addTarget(self, action: #selector(registerBtnTapped(_:)), for: .touchUpInside)
            
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.color = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 1.0)
        activityIndicator.backgroundColor = UIColor.gray

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func registerBtnTapped(_ sender:Any) {
        
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.main)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC")
        self.navigationController?.pushViewController(registerVC, animated: true)
    }

    func loginBtnTapped(_ sender:Any) {
        
        activityIndicator.startAnimating()
        
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else {
                return
        }
        
        if emailTextField.text == "" {
            
            self.warningAlert(warningMessage: "Please enter your email")
            
        } else if password == "" || password.characters.count < 6 {
            
            self.warningAlert(warningMessage: "Please enter your password")
            
        } else {
            
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                
                if let validError = error {
                    
                    print(validError.localizedDescription)
                    
                    self.warningAlert(warningMessage: "Please enter your email or password correctly!")
                    
                    return
                }
                
                print("User exist \(user?.uid ?? "")")
                
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC")
                self.present(mainVC, animated: true, completion: nil)
                self.activityIndicator.stopAnimating()
                self.emailTextField.text = nil
                self.passwordTextField.text = nil
                
            })
        }
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if let error = error {
            
            print(error.localizedDescription)
            warningAlert(warningMessage: "Please try again")
            return
            
        } else if ( result.isCancelled == true) {
            
            print("cancelled")
            
        } else {
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                
                print("User logged into Firebase")
                
                let ref = Database.database().reference(fromURL: "https://chillup-9cdcd.firebaseio.com/")
                
                guard let uid = user?.uid else {
                    
                    return
                }
                
                let userRef = ref.child("users").child(uid)
                
                let graphRequest: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,name,email"])
                
                graphRequest.start(completionHandler: { (connection, result, error) in
                    
                    if error != nil {
                        
                        print("\(String(describing: error))")
                        
                    } else {
                        
                        let values : [String:Any] = result as! [String:Any]
                        
                        userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                            
                            if error != nil {
                                
                                print("\(String(describing: error))")
                                
                                return
                            }
                            
                            print("Save the user into Firebase")
                        })
                    }
                })
            })
            
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let mainVC = storyboard.instantiateViewController(withIdentifier: "TabBarNavi")
            self.present(mainVC, animated: true, completion: nil)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        print("Facebook logged out")
        warningAlert(warningMessage: "Facebook logged out")
    }
    
    func setupSpinner() {
        
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTextField {
            
            passwordTextField.becomeFirstResponder()
            
        } else if textField == passwordTextField {
            
            passwordTextField.resignFirstResponder()
        }
        
        return true
    }
    
    func warningAlert(warningMessage: String) {
        let alertController = UIAlertController(title: "Error", message: warningMessage, preferredStyle: .alert)
        let ok = UIAlertAction(title:"OK", style: .cancel, handler: nil)
        alertController.addAction(ok)
        
        present(alertController, animated: true, completion: nil)
        self.activityIndicator.stopAnimating()
        
    }

}
