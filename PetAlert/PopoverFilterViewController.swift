//
//  PopoverFilterViewController.swift
//  PetAlert
//
//  Created by Claudia on 01.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class PopoverFilterViewController: UIViewController {

    @IBAction func setSliderValueChanged(_ sender: UISlider) {
        let sliderValue = Int(sender.value)
//        print ("ValueChanged", sliderValue)
        radiusLbl.text = "\(sliderValue)"
        Shared.shared.radiusValue = sliderValue
    }
    
    @IBOutlet weak var breedInput: UITextField!
    
    @IBAction func breedInputAction(_ sender: UITextField) {
        Shared.shared.breedValue = breedInput.text!
    }
    
    @IBOutlet weak var radiusLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radiusLbl.text = "\(Shared.shared.radiusValue)"
        breedInput.text = "\(Shared.shared.breedValue)"

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
