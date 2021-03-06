//
//  FirstPageVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 20/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit

class FirstPageVC: UIViewController {
    
    @IBOutlet weak var signInBtn: UIButton! {
        
        didSet {
            
            signInBtn.addTarget(self, action: #selector(signInBtnTapped(_:)), for: .touchUpInside)
            signInBtn.layer.cornerRadius = 15
            signInBtn.layer.borderWidth = 1
            signInBtn.layer.borderColor = UIColor.black.cgColor
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    func signInBtnTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.main)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
    func signUpBtnTapped(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Auth", bundle: Bundle.main)
        let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
}
