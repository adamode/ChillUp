//
//  SearchCell.swift
//  ChillUp
//
//  Created by Mohd Adam on 19/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    var searchCell: ChillData?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
