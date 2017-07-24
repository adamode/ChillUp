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
            tableView.layer.masksToBounds = true
            tableView.layer.borderColor = UIColor( red: 153/255, green: 153/255, blue:0/255, alpha: 1.0 ).cgColor
            tableView.layer.borderWidth = 1.0
        }
    }
    
    var events : [ChillData] = []
    
    var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchEvents()
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        refresher.tintColor = UIColor(red:0.25, green:0.72, blue:0.85, alpha:1.0)
        tableView.addSubview(refresher)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    func handleRefresh() {
        
        self.events = []
        fetchEvents()
        refresher.endRefreshing()
        tableView.reloadData()
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
