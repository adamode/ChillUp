//
//  EditVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 18/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit

class EditVC: UIViewController {

    @IBOutlet weak var closeBtn: UIButton! {
        
        didSet {
            
            closeBtn.addTarget(self, action: #selector(closeBtnTapped(_:)), for: .touchUpInside)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func closeBtnTapped(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

}
