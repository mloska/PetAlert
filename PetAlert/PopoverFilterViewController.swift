//
//  PopoverFilterViewController.swift
//  PetAlert
//
//  Created by Claudia on 01.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class PopoverFilterViewController: UIViewController {

    @IBOutlet weak var btnBreed: UIButton!
    
    
    @IBAction func setSliderValueChanged(_ sender: UISlider) {
        let sliderValue = Int(sender.value)
//        print ("ValueChanged", sliderValue)
        radiusLbl.text = "\(sliderValue)"
        Shared.shared.radiusValue = sliderValue
    }
    
    
    @IBOutlet weak var radiusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radiusLbl.text = "\(Shared.shared.radiusValue)"

        btnBreed.backgroundColor = .clear
        btnBreed.layer.cornerRadius = 5
        btnBreed.layer.borderWidth = 0.5
        btnBreed.layer.borderColor = UIColor.lightGray.cgColor
        
        let label : String = Shared.shared.breedChoice
        btnBreed.setTitle(label, for: .normal)

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let label : String = Shared.shared.breedChoice
        btnBreed.setTitle(label, for: .normal)
    }


}
