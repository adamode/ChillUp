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
    
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var getUsername: UILabel!
    @IBOutlet weak var getLocation: UILabel!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var TimeandDateLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var rsvpBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.getUsername.text = getCell?.name
        self.getLocation.text = "N/A"
        self.eventTitle.text = getCell?.eventName
        self.descriptionLabel.text = getCell?.eventDescription
        self.TimeandDateLabel.text = getCell?.eventDateandTime
        self.eventImageView.sd_setImage(with: getCell?.imageURL)

    }


}
