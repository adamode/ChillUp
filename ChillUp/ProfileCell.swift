//
//  ProfileCell.swift
//  ChillUp
//
//  Created by Mohd Adam on 18/07/2017.
//  Copyright © 2017 Mohd Adam. All rights reserved.
//

import UIKit

class ProfileCell: UITableViewCell {

    @IBOutlet weak var profileCellImage: UIImageView!
    @IBOutlet weak var profileCellTitle: UILabel!
    @IBOutlet weak var profileCellDescription: UILabel!
    
    var profileCell: ChillData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
