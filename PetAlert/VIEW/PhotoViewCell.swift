//
//  PhotoViewCell.swift
//  PetAlert
//
//  Created by Mateusz Loska on 22/01/2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class PhotoViewCell: UICollectionViewCell {
    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petName: UILabel!
    
    func updateViews(pet: Pet)
    {
        petPicture.image = UIImage(named: pet.Image!);
        petName.text = pet.Name
    }
}
