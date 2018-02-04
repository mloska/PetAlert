//
//  ChooseBreedViewController.swift
//  PetAlert
//
//  Created by Claudia on 03.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class ChooseBreedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    class Breed {
        var ID: Int?
        var name: String?
        var subName: String?
        var image: UIImage?
        
        init(ID: Int? = 0, name: String? = nil, subName: String? = nil, image: UIImage? = UIImage()) {
            self.ID = ID
            self.name = name
            self.subName = subName
            self.image = image
        }

    }
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var breedView: UIView!
    
    var allBreeds = [Breed]()
    var searchedBreeds = [Breed]()

    var allBreeds2 = [
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
    
    
    func sampleData(){
        allBreeds.append(Breed(name: "Affenpinscher", subName: "Pinczer małpi", image: UIImage()))
        allBreeds.append(Breed(name: "Aidi", subName: "Owczarek z Gór Atlas", image: UIImage()))
        allBreeds.append(Breed(name: "Airedale terrier", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Akbash dog", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Akita", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Akita amerykańska", subName: "Duży japoński pies", image: UIImage()))
        allBreeds.append(Breed(name: "Alano español", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Alaskan husky", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Alaskan klee kai", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Alaskan malamute", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Alpejski gończy krótkonożny", subName: "Alpine Dachsbracke", image: UIImage()))
        allBreeds.append(Breed(name: "Amerykański pies eskimoski", subName: "American eskimo dog", image: UIImage()))
        allBreeds.append(Breed(name: "Amerykański pitbulterier", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Amerykański spaniel dowodny", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Amerykański staffordshire terier", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Alaskan malamute", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Anatolian", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Angielski Coonhound", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Appenzeller", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Ariégeois", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Australian Cattle Dog", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Australian stumpy tail cattle dog", subName: "", image: UIImage()))
        allBreeds.append(Breed(name: "Australijski silky terier", subName: "", image: UIImage()))
    }
    
    let URL_GET_BREEDS_STR = "https://serwer1878270.home.pl/WebService/api/getallbreeds.php"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // establish connection for passing link and fire the main function
        connectToJson(link: URL_GET_BREEDS_STR, jsonTitle: "breeds", mainFunctionName: mainChooseBreedFunction)

        //sampleData()
        tableView.delegate = self
        tableView.dataSource = self

        breedView.layer.cornerRadius = 10
        breedView.layer.masksToBounds = true
        
        searchBar.delegate = self

    
    }
    
    func mainChooseBreedFunction (passedJsonArray: [[String: Any]]) {
        // return to main array for this controller results from choped json into single objects in array
        self.allBreeds = JsonBreedToArray(inputJsonArray: passedJsonArray, downloadThumbnail: true)
        
        searchedBreeds = allBreeds

        self.tableView.reloadData()
        
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Shared.shared.breedChoice = searchedBreeds[indexPath.row].name!
        dismiss(animated: true, completion: nil)
    }

 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedBreeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "breedCell") as! CustomBreedTableViewCell
        cell.breedView.layer.cornerRadius = cell.breedView.frame.height / 2
        cell.breedImage.layer.cornerRadius = cell.breedImage.frame.height / 2
        
        let breedObject = searchedBreeds[indexPath.row]
        cell.breedNameLabel.text = "\(breedObject.name ?? "")"
        cell.breedSubname.text = "\(breedObject.subName ?? "")"
        cell.breedImage.image = breedObject.image
        
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else
        {
            searchedBreeds = allBreeds
            tableView.reloadData()
            return
        }
        
        searchedBreeds = allBreeds.filter({ breed -> Bool in
            (breed.name?.lowercased().contains(searchText.lowercased() ))! ||
                (breed.subName?.lowercased().contains(searchText.lowercased() ))!

        })
        tableView.reloadData()
    }
    

}
