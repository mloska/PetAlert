//
//  FirstViewController.swift
//  PetAlert
//
//  Created by Claudia on 06.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginTapped(_ sender: Any) {
        let mainTabController = storyboard?.instantiateViewController(withIdentifier: "MainTabController") as! MainTabController
        mainTabController.selectedViewController = mainTabController.viewControllers?[2]
        present(mainTabController, animated: true, completion: nil)
        // store userID
        
    }
    
}

