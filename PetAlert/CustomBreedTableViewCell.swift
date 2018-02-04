//
//  CustomTableViewCell.swift
//  PetAlert
//
//  Created by Claudia on 03.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class CustomBreedTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var breedNameLabel: UILabel!
    @IBOutlet weak var breedSubname: UILabel!
    @IBOutlet weak var breedImage: UIImageView!
    @IBOutlet weak var breedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

