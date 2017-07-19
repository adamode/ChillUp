//
//  MainVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class MainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
            
        }
    }
    
    var events : [ChillData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEvents()

    }
    
    func fetchEvents() {
        
        let ref = Database.database().reference()
        
        ref.child("posts").observe(.childAdded, with: { (snapshot) in
            
            if let data = ChillData(snapshot: snapshot) {
                    
                    self.events.append(data)
                
            }
                self.tableView.reloadData()
            
        })
    }

}

extension MainVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MeetupCell
        
        let data = events[indexPath.row]
        
        cell.titleLabel.text = data.eventName
        cell.descriptionLabel.text = data.eventDescription
        cell.cellImageView.sd_setImage(with: data.imageURL)
        
        return cell
        
    }
}


extension MainVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chill = events[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let selectedVC = storyboard.instantiateViewController(withIdentifier: "SelectedCellVC") as! SelectedCellVC
        
        selectedVC.getCell = chill
        
        self.navigationController?.pushViewController(selectedVC, animated: true)
    
    }
}
