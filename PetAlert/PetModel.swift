//
//  PetModel.swift
//  PetAlert
//
//  Created by Claudia on 06.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import Foundation
import UIKit

class Pet : NSObject{
    var ID:             Int?
    var Name:           String?
    var Breed:          String?
    var Color:          String?
    var City:           String?
    var Street:         String?
    var PetType:        String?
    var Description:    String?
    var LastDate:       String?
    var Longitude:      Double = 0.0
    var Latitude:       Double = 0.0
    var Status:         String? //StatusTypeEnum?
    var Image:          String?
    var ImageData:      UIImage? 
    var UserID:         Int?
    var UUID:           String?
    var DateTimeModification:  NSDate?
    
    override init(){
        
    }
    
    init(
        ID: Int?,
        Name: String?,
        Breed: String?,
        Color: String?,
        City: String?,
        Street: String?,
        PetType: String?,
        Description: String?,
        LastDate: String?,
        Longitude: Double?,
        Latitude: Double?,
        Status: String?,
        Image: String?,
        ImageData: UIImage?,
        UserID: Int?,
        UUID: String?,
        DateTimeModification: NSDate?) {
        self.ID = ID
        self.Name = Name
        self.Breed = Breed
        self.Color = Color
        self.City = City
        self.Street = Street
        self.PetType = PetType
        self.Description = Description
        self.LastDate = LastDate
        self.Longitude = Longitude!
        self.Latitude = Latitude!
        self.Status = Status
        self.Image = Image
        self.ImageData = ImageData
        self.UserID = UserID
        self.UUID = UUID
        self.DateTimeModification = DateTimeModification
    }
}


// establish connection for passing webservice link, pass function that need to be fired in the main thread
func connectToJson(link: String, mainFunctionName: @escaping ([[String: Any]]) -> Void){
    let url = URL(string: link)!
    var request = URLRequest(url:url)
    request.httpMethod = "GET"
    
    var jsonResult: [String: Any] = [:]
    var pets: [[String: Any]] = [[:]]
    
    
    let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
        if (error != nil) {
            print("error: ", error ?? "")
        } else {
            if data != nil{
                do {
                    jsonResult = try JSONSerialization.jsonObject(with: data!, options:.mutableContainers) as! [String : Any]
                    pets = (jsonResult["pets"] as? [[String: Any]])!
                    
                    DispatchQueue.main.sync(execute: {
                        
                        mainFunctionName (pets)
                        
                    })
                } catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    task.resume()
}

// chop Json array into single objects
func JsonToArray (inputJsonArray : [[String: Any]]) -> [Pet]{
    let URL_PHOTOS_MAIN_STR = "https://serwer1878270.home.pl/Images/User_"
    var petsArrayReturn:[Pet]? = []
    
    for pet in inputJsonArray {
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
        
        let imgURL = "\(URL_PHOTOS_MAIN_STR)" + "\(petObject.UserID!)" + "/" + "\(petObject.UUID!)" + ".jpg"
        
        let url = URL(string:imgURL)
        if let data = try? Data(contentsOf: url!)
        {
            petObject.ImageData = UIImage(data: data)
        }
        
        petsArrayReturn?.append(petObject)
    }
    
    return petsArrayReturn!
}




enum petStatuses : Int {
    case Searching = 1, Spotted = 2, Found = 3
}

let a: petStatuses? = petStatuses(rawValue: 2) // Spotted
let b: petStatuses = .Spotted // 2



class PetLocalization{
    var Longitude:      Float = 0.0
    var Latitude:       Float = 0.0
}

class PetStreetLocalization{
    var Street:      String?
    var Town:        String?
}

enum StatusTypeEnum {
    case LookingFor
    case Found
    case Spotted
}

enum PetTypeEnum {
    case Dog
    case Cat
    case Bird
}

