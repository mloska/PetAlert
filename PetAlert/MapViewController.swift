//
//  MapViewController.swift
//  PetAlert
//
//  Created by Claudia on 07.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!

    //Our web service url
    let URL_GET_TEAMS = URL(string: "https://serwer1878270.home.pl/WebService/api/getallpets.php")
    let URL_GET_TEAMS_STR = "https://serwer1878270.home.pl/WebService/api/getallpets.php"
    let URL_PHOTOS_MAIN_STR = "https://serwer1878270.home.pl/Images/User_"
    
    var petsArrayMap:[Pet]? = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var names = ["Leon", "Ares", "Hektor", "Eden", "Drops", "Zora", "Koda", "Amber", "Atan", "Natan", "Piorun", "Paco", "Rox", "Fafik", "Bąbel", "Bambi", "Amor", "Baks", "Coco", "Micka"]
//        var latitude = [50.09000833, 50.10635068, 50.15258778, 50.0406191, 50.05985175, 50.07332046, 50.14757413, 50.15044122, 50.10997714, 50.0558049, 50.088566, 50.13715946, 50.0990909, 50.05216344, 49.99223714, 50.10933517, 49.98568133, 50.01387256, 50.07015543, 50.14930141]
//        var longitude = [20.01274005, 20.0681771, 19.95851556, 19.91279338, 19.81823311, 19.93518523, 19.9667472, 19.92463495, 19.85944606, 19.87102005, 19.75631217, 19.96753202, 20.12630022, 20.13657324, 20.06941245, 20.06932906, 20.05847755, 19.99495258, 19.97558074, 19.93061267]
        
        //var petsArray = [Pet]()
        let lat = 50.09000833
        let long = 20.01274005
        get_data_from_url(URL_GET_TEAMS_STR)

        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 10.0)
        let map = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        
        self.mapView.camera = camera;
        self.mapView = map
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                
                petsArrayMap?.append(petObject)
                
                
            }

        }
        
        DispatchQueue.main.async {
            for pet:Pet in self.petsArrayMap! {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
                marker.title = pet.Name
                marker.snippet = "Hey, this is \(pet.Name ?? "")"
                marker.map = self.mapView
            }
            
        }
        
        OperationQueue.main.addOperation ({
            for pet:Pet in self.petsArrayMap! {
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: pet.Latitude, longitude: pet.Longitude)
                marker.title = pet.Name
                marker.snippet = "Hey, this is \(pet.Name ?? "")"
                marker.map = self.mapView
            }
            
        })
        
    }
    
}


