//
//  CustomTableViewCell.swift
//  PetAlert
//
//  Created by Claudia on 08.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellSubtitle: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
