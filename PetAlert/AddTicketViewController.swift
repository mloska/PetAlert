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

    var petsArray:[Pet]? = []
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    
    //Our web service url
    let URL_GET_TEAMS = URL(string: "https://serwer1878270.home.pl/WebService/api/getallpets.php")
    let URL_GET_TEAMS_STR = "https://serwer1878270.home.pl/WebService/api/getallpets.php"
    let URL_PHOTOS_MAIN_STR = "https://serwer1878270.home.pl/Images/User_"

    override func viewDidLoad() {
        super.viewDidLoad()
        get_data_from_url(URL_GET_TEAMS_STR)
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
    
    
    func get_data_from_url(_ link:String)
    {
        let url:URL = URL(string: link)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            self.extract_json(data!)
            
        })
        
        task.resume()
        
    }
    
    
    func extract_json(_ data: Data)
    {
        var json: [String: Any] = [:]
        var pets: [[String: Any]] = [[:]]

        do
        {
            json = (try JSONSerialization.jsonObject(with: data) as? [String: Any])!
            pets = (json["pets"] as? [[String: Any]])!
        }
        catch
        {
            return
        }
        
        guard let data_list = json as?  [String: Any] else
        {
            return
        }
        
        
        if let pets_list = json as?  [String: Any]
        {
            
            for pet in pets {
                let petObject:Pet = Pet()
                
                if let id = pet["ID"] as? Int                       {  petObject.ID = id  }
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
              
                if (petObject.Status == "1"){
                    petObject.Status = "Searching"
                }
                else if (petObject.Status == "2"){
                    petObject.Status = "Spotted"
                }
                else if (petObject.Status == "3"){
                    petObject.Status = "Found"
                }
                
                let imgURL = "\(URL_PHOTOS_MAIN_STR)" + "\(petObject.UserID!)" + "/" + "\(petObject.ID!)" + ".jpg"
                
                let url = URL(string:imgURL)
                if let data = try? Data(contentsOf: url!)
                {
                    petObject.ImageData = UIImage(data: data)
                }
                
                petsArray?.append(petObject)
            }
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        OperationQueue.main.addOperation ({
            self.tableView.reloadData()
        })

    }
    
    @objc func refresh(_ sender: Any) {
        get_data_from_url(URL_GET_TEAMS_STR)
        tableView.reloadData()
        print("reloaded, counted pets:", petsArray?.count ?? 0)
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
        return petsArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell

        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.cellImage.layer.cornerRadius = cell.cellImage.frame.height / 2
        
        let petObject = petsArray![indexPath.row]
        
        cell.cellTitle.text = "\(petObject.Color!) \(petObject.Breed!)" + " (" +  "\(petObject.Name!)" + ")"
        cell.cellSubtitle.text = "\(petObject.Street!), \(petObject.City!)"
        cell.cellImage.image = petObject.ImageData
        
        if (petObject.Status == "Searching") {
            cell.cellView.backgroundColor = .green
        }
        else if (petObject.Status == "Found") {
            cell.cellView.backgroundColor = .purple
            cell.cellTitle.textColor = .red
            cell.cellSubtitle.textColor = .red
        }
        else if (petObject.Status == "Spotted") {
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

        if let destination = segue.destination as? DetailsTicketViewController {

            let counter = tableView.indexPathForSelectedRow?.row
            let petObject = petsArray![counter!]

            destination.destPet = petObject
        }
    }
    

    
}


