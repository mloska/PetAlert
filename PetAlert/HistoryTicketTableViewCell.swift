//
//  HistoryTicketTableViewCell.swift
//  PetAlert
//
//  Created by Claudia on 07.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class HistoryTicketTableViewCell: UITableViewCell {

    @IBOutlet weak var imageHist: UIImageView!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
