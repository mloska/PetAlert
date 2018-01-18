//
//  SecondViewController.swift
//  PetAlert
//
//  Created by Claudia on 06.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import CoreData

class AddTicketViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var names = ["Leon", "Ares", "Hektor", "Eden", "Drops", "Zora", "Koda", "Amber", "Atan", "Natan", "Piorun", "Paco", "Rox", "Fafik", "Bąbel", "Bambi", "Amor", "Baks", "Coco", "Micka"]
    //var petType:PetTypeEnum = "Dog"
    var breed = ["kundel", "Rottweiler", "wilczur", "Beagle", "owczarek", "mieszaniec", "kundel", "Labrador", "dalmatyńczyk", "Beagle", "Yorkshire", "kundel", "York", "Owczarek szkocki", "kundel", "wilczur", "Labrador", "owczarek", "Beagle", "Maltese Terrier"]
    var color = ["biało czarny", "czarny", "jasny", "brązowy", "czarny", "czarny", "czarno-brązowy", "jasny", "czarno-biały", "jasny", "jasno brązowy", "jasno brązowy", "biało-czarny", "brązowy", "biały", "brązowo-czarny", "biały", "jasno brązowy", "brązowy", "biały"]
    var photos = ["1_kundel", "2_rottweiler", "3_wilczur", "4_beagle", "5_owczarek", "6_mieszaniec", "7_kundel", "8_LabradorRetriever", "9_dalmatynczyk", "10_beagle", "11_YorkshireTerrier", "12_kundel", "13_yorkBiewer", "14_owczarekSzkocki", "15_kundel", "16_wilczur", "17_labrador", "18_owczarek", "19_beagle", "20_MalteseTerrier"]
    var cities = ["Kraków", "Chrzanów", "Warszawa", "Częstochowa", "Łódź", "Giżycko", "Poznoń", "Wałbrzyk", "Słupsk", "Gdańsk", "Koszalin", "Szczecin", "Legnica", "Wrocław", "Tarnów", "Rzeszów", "Skarżysko Kamienna", "Radom", "Jasło", "Kętrzyn"]
    var streets = ["Racławicka 20", "Warszawska 170", "Jana Pawła II 80", "Czarnowiejska 18b", "Lea 20-22", "Królewska 15b", "Jasnogórska 189", "Aleje 29 listopada 123", "Raciborska 15-16", "Szuwarowa 19", "Grota Roweckiego 188", "Powstańców Śląskich 199", "Studencka 11", "Wzgórza 11", "Koszalińska 12", "Wyszyńskiego 11", "Aleje Adama Mickiewicza 44", "Aleje 3go Maja", "Poniatowskiego 288", "Górna 190"]
    var latitude = [50.09000833, 50.10635068, 50.15258778, 50.0406191, 50.05985175, 50.07332046, 50.14757413, 50.15044122, 50.10997714, 50.0558049, 50.088566, 50.13715946, 50.0990909, 50.05216344, 49.99223714, 50.10933517, 49.98568133, 50.01387256, 50.07015543, 50.14930141]
    var longitude = [20.01274005, 20.0681771, 19.95851556, 19.91279338, 19.81823311, 19.93518523, 19.9667472, 19.92463495, 19.85944606, 19.87102005, 19.75631217, 19.96753202, 20.12630022, 20.13657324, 20.06941245, 20.06932906, 20.05847755, 19.99495258, 19.97558074, 19.93061267]
    
    var pets:[PetEntity]? = nil
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    //Our web service url
    let URL_GET_TEAMS = URL(string: "https://serwer1878270.home.pl/WebService/api/getallpets.php")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        pets = CoreDataHelper.fetchObject()

        if pets?.count == 0 {
            for i in 0...names.count-1 {
                CoreDataHelper.saveObject(
                    name: names[i],
                    breed: breed[i],
                    color: color[i],
                    status: "",
                    image: photos[i],
                    city: cities[i],
                    street: streets[i],
                    longitude: longitude[i],
                    latitude: latitude[i],
                    lastdate: "",
                    uuid: "",
                    dateTimeModification: NSDate(),
                    imageBinary: UIImagePNGRepresentation(UIImage(named: photos[i])!)! as NSData,
                    petType: "Dog",
                    userID: Int32(i)
                )
            }
        }
        
        print(pets?.count ?? 0)
//        for i in pets! {
//            print(i.dateTimeModification ?? "")
//        }
        
        
        
        
        
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: URL_GET_TEAMS!)
        
        //setting the method to post
        request.httpMethod = "GET"
        
        
        
        
        
        
        
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            //exiting if there is some error
            if error != nil{
                print("error is \(error ?? "" as! Error)")
                return;
            }
            
            
            //var names = [String]()
            let petObject = Pet()
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let pets = json["pets"] as? [[String: Any]] {
                    for pet in pets {
                        if let id = pet["ID"] as? Int                    {  petObject.ID = id  }
                        if let name = pet["Name"] as? String                {  petObject.Name = name  }
                        if let breed = pet["Breed"] as? String              {  petObject.Breed = breed  }
                        if let color = pet["Color"] as? String              {  petObject.Color = color  }
                        if let city = pet["City"] as? String                {  petObject.City = city  }
                        if let street = pet["Street"] as? String            {  petObject.Street = street  }
                        if let petType = pet["PetType"] as? String          {  petObject.PetType = petType  }
                        if let description = pet["Description"] as? String  {  petObject.Description = description  }
                        if let lastDate = pet["LastDate"] as? String        {  petObject.LastDate = lastDate  }
                        if let longitude = pet["Longitude"] as? Double      {  petObject.Longitude = longitude  }
                        if let latitude = pet["Latitude"] as? Double        {  petObject.Latitude = latitude  }
                        if let status = pet["Status"] as? String            {  petObject.Status = status  }
                        if let image = pet["Image"] as? String              {  petObject.Image = image  }
                        if let userID = pet["UserID"] as? Int               {  petObject.UserID = userID  }
                        if let uuid = pet["UUID"] as? String                {  petObject.UUID = uuid  }
                        if let dateTimeModification = pet["DateTimeModification"] as? NSDate {  petObject.DateTimeModification = dateTimeModification  }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
            //print(names)
        }
            
//            //parsing the response
//            do {
//                //converting resonse to NSDictionary
//                //var teamJSON: NSDictionary!
//                //teamJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
//                //var teamJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any]
//                let teamJSON = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
//                //let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
//
//
//
//                //parsing the json
//                if let parseJSON = teamJSON {
//
//                    //creating a string
//                    var msg : String!
//
//                    //getting the json response
//                    msg = parseJSON["ID"] as! String?
//
//                    //printing the response
//                    print(msg)
//
//                }
//            } catch {
//                print(error)
//            }
//
//        }
            
                //getting the JSON array teams from the response
                //let pets: NSArray = teamJSON["pets"] as! NSArray
//                let pets: [String: Any] = teamJSON!["pets"] as! [String : Any]
//
//                //looping through all the json objects in the array teams
//                for i in 0 ..< pets.count{
//
//                    //getting the data at each index
//                    let teamId = pets[i]["ID"] as? [String: Any]
//                    let teamName:String = pets[i]!["Name"] as! String!
//                    let teamMember:Int = pets[i]!["Breed"] as! Int!
            
//                    let team1 = teams[i] as! NSDictionary // remind it is a NSDictionary and not ANy
//                    let teamId2:Int = team1["id"]! as! Int
//                    let teamName2:String = team1["name"]! as! String
//                    let teamMember2:Int = team1["member"]! as! Int
//
//                    let teamId3:Int = (teams[i] as! NSDictionary)[“id”] as! Int!
//                    let teamName3:String = (teams[i] as! NSDictionary)[“name”] as! String!
//                    let teamMember3:Int = (teams[i] as! NSDictionary)[“member”] as! Int!
//
//
//
//
//                    //getting the JSON array teams from the response
//                    let data: NSArray = teamJSON[“data”] as! NSArray
//                    if let dataArr = data as? [[String: Any]] {
//                        for product in dataArr {
//                            //your code for accessing dd.
//                            let id:String = product[“id”] as! String
//                            let name:String = product[“name”] as! String
//                            let price:String = product[“price”] as! String
//                            let picture:String = product[“picture”] as! String
//
//                            let newProduct = Products(id: id,name: name,price: price,picture: picture,url: “”)
//
//                            self.product.append(newProduct)
                    
                    
                    
                    
                    //displaying the data
//                    print("id -> ", teamId)
//                    print("name -> ", teamName)
//                    print("member -> ", teamMember)
//                    print("===================")
//                    print("")
//
//                }
//
//            } catch {
//                print(error)
//            }
//        }
        //executing the task
        task.resume()
        
        
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        tableView.addGestureRecognizer(gesture)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func refresh(_ sender: Any) {
        pets = CoreDataHelper.fetchObject()
        tableView.reloadData()
        print("reloaded, counted pets:", pets?.count ?? 0)
        refreshControl.endRefreshing()
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        //Here you should implement your checks for the swipe gesture
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell

        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.cellImage.layer.cornerRadius = cell.cellImage.frame.height / 2

        let petObject = pets![indexPath.row]
        let petColor = petObject.value(forKey: "color")
        let petBreed = petObject.value(forKey: "breed")
        let petName = petObject.value(forKey: "name")
        let petStreet = petObject.value(forKey: "street")
        let petCity = petObject.value(forKey: "city")
        let petImageBinary = petObject.value(forKey: "imageBinary") ?? NSData()
        let petStatus = petObject.value(forKey: "status") as? String ?? ""

        cell.cellTitle.text = "\(petColor!) \(petBreed!)" + " (" +  "\(petName!)" + ")"
        cell.cellSubtitle.text = "\(petStreet!), \(petCity!)"
        cell.cellImage.image = UIImage(data: petImageBinary as! Data)

        if (petStatus == "Searching") {
            cell.cellView.backgroundColor = .green
        }
        else if (petStatus == "Found") {
            cell.cellView.backgroundColor = .purple
            cell.cellTitle.textColor = .red
            cell.cellSubtitle.textColor = .red
        }
        else if (petStatus == "Spotted") {
            cell.cellView.backgroundColor = .orange
            cell.cellTitle.textColor = .black
            cell.cellSubtitle.textColor = .black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTicketDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        pets = CoreDataHelper.fetchObject()
        
        if let destination = segue.destination as? DetailsTicketViewController {

            let counter = tableView.indexPathForSelectedRow?.row
            let petObject = pets![counter!]
//            let petName = petObject.value(forKey: "name")
//            let petColor = petObject.value(forKey: "color")
//            let petBreed = petObject.value(forKey: "breed")
//            let petStreet = petObject.value(forKey: "street")
//            let petCity = petObject.value(forKey: "city")
//            let petImage = petObject.value(forKey: "image")
            
            destination.destPet = petObject
        }
    }
    
    
}



