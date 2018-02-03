//
//  ChooseBreedViewController.swift
//  PetAlert
//
//  Created by Claudia on 03.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class ChooseBreedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var breedView: UIView!
    
    var allBreeds = ["Affenpinscher (Pinczer małpi)",
                     "Aidi (Owczarek z Gór Atlas)",
                     "Airedale terrier",
                     "Akbash dog",
                     "Akita",
                     "Akita amerykańska (Duży japoński pies)",
                     "Alano español",
                     "Alaskan husky",
                     "Alaskan klee kai",
                     "Alaskan malamute",
                     "Alpejski gończy krótkonożny (Alpine Dachsbracke)",
                     "American eskimo dog (Amerykański pies eskimoski)",
                     "Amerykański pitbulterier",
                     "Amerykański spaniel dowodny",
                     "Amerykański staffordshire terier",
                     "Anatolian",
                     "Angielski Coonhound",
                     "Appenzeller",
                     "Ariégeois",
                     "Australian Cattle Dog",
                     "Australian stumpy tail cattle dog",
                     "Australijski silky terier",
                     
                     "Barbet",
                     "Basenji",
                     "Basset",
                     "Basset artezyjsko-normandzki",
                     "Basset bretoński",
                     "Basset gaskoński",
                     "Beagle",
                     "Beagle harrier",
                     "Bearded collie",
                     "Bedlington terier",
                     "Bernardyn długowłosy",
                     "Bernardyn krótkowłosy",
                     "Berneński pies pasterski",
                     "Biały owczarek szwajcarski",
                     "Biewer Yorkshire Terrier",
                     "Bichon frise",
                     "Black and tan Coonhound",
                     "Bloodhound",
                     "Bluetick Coonhound",
                     "Boerboel",
                     "Bokser",
                     "Bolończyk",
                     "Border collie",
                     "Border terrier",
                     "Boston terier",
                     "Bouvier des Ardennes",
                     "Bouvier des Flandres",
                     "Boykin spaniel",
                     "Brabantczyk",
                     "Braque d'Auvergne",
                     "Braque du Bourbonnais",
                     "Braque Saint-Germain",
                     "Briquet Griffon Vendéen",
                     "Broholmer",
                     "Buhund norweski",
                     "Buldog amerykański",
                     "Buldog angielski",
                     "Buldog francuski",
                     "Bully Kutta",
                     "Bulmastif",
                     "Bulterier",
                     "Bulterier miniaturowy"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

        breedView.layer.cornerRadius = 10
        breedView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Shared.shared.breedChoice = allBreeds[indexPath.row]
        dismiss(animated: true, completion: nil)
//        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
//        self.present(newViewController, animated: true, completion: nil)
//
    }

 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allBreeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedCell") as! CustomBreedTableViewCell
        cell.breedView.layer.cornerRadius = cell.breedView.frame.height / 2
        cell.breedImage.layer.cornerRadius = cell.breedImage.frame.height / 2
        
        let breedObject = allBreeds[indexPath.row]
        cell.breedNameLabel.text = "\(breedObject)"
        //cell.cellImage.image = breedObject.ImageData
        
        return cell
    }
    

}
