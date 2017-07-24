//
//  SearchVC.swift
//  ChillUp
//
//  Created by Mohd Adam on 17/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class SearchVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!{
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
            tableView.layer.masksToBounds = true
            tableView.layer.borderColor = UIColor( red: 153/255, green: 153/255, blue:0/255, alpha: 1.0 ).cgColor
            tableView.layer.borderWidth = 1.0
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        
        didSet {
            
            searchBar.delegate = self
        }
    }
    
    var getAllPost: [ChillData] = []
    var filteredPost: [ChillData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllPost()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        
    }
    
    func fetchAllPost() {
        
        let ref = Database.database().reference()
        
        ref.child("posts").observe(.childAdded, with: { (snapshot) in
            
            if let data = ChillData(snapshot: snapshot) {
                
                self.getAllPost.append(data)
            }
            
            self.filteredPost = self.getAllPost
            
            self.tableView.reloadData()
        })
    }
    
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredPost.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchCell
        
        let data = filteredPost[indexPath.row]
        
        cell.cellLabel?.text = data.eventName
        
        cell.cellImageView.sd_setImage(with: data.imageURL)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let chill = filteredPost[indexPath.row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let selectedVC = storyboard.instantiateViewController(withIdentifier: "SelectedCellVC") as! SelectedCellVC
        
        selectedVC.getCell = chill
        
        self.navigationController?.pushViewController(selectedVC, animated: true)
        
    }
}

extension SearchVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredPost = searchText.isEmpty ? getAllPost : getAllPost.filter { (item: ChillData) -> Bool in
            return item.eventName?.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        searchBar.showsCancelButton = true
        
    }
}

