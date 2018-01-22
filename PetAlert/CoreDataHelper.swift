//
//  CoreDataHelper.swift
//  PetAlert
//
//  Created by Claudia on 13.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataHelper: NSObject {
    //MARK: - Video Part 1
    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    class func saveObject(
        name: String,
        breed: String,
        color: String,
        status: String,
        image: String,
        city: String,
        street: String,
        longitude: Double,
        latitude: Double,
        lastdate: String,
        uuid: String,
        dateTimeModification: NSDate,
        imageBinary: NSData,
        petType: String,
        userID: Int32) -> Bool {
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "PetEntity", in: context)
        let petItem = NSManagedObject(entity: entity!, insertInto: context)
        
        petItem.setValue(name, forKey: "name")
        petItem.setValue(breed, forKey: "breed")
        petItem.setValue(color, forKey: "color")
        petItem.setValue(status, forKey: "status")
        petItem.setValue(image, forKey: "image")
        petItem.setValue(city, forKey: "city")
        petItem.setValue(street, forKey: "street")
        petItem.setValue(longitude, forKey: "longitude")
        petItem.setValue(latitude, forKey: "latitude")
        petItem.setValue(lastdate, forKey: "lastdate")
        petItem.setValue(uuid, forKey: "uuid")
        petItem.setValue(imageBinary, forKey: "imageBinary")
        petItem.setValue(dateTimeModification, forKey: "dateTimeModification")
        petItem.setValue(petType, forKey: "petType")
        petItem.setValue(userID, forKey: "userID")

        do {
            try context.save()
            return true
        }catch {
            return false
        }
    }
    
    class func fetchObject() -> [PetEntity]? {
        let context = getContext()
        var listOfPets:[PetEntity]? = nil
        
        do {
            //pet = try context.fetch(PetEntity.fetchRequest())
            let fetchRequest: NSFetchRequest<PetEntity> = PetEntity.fetchRequest()
            let sectionSortDescriptor = NSSortDescriptor(key: "dateTimeModification", ascending: false)
            let sortDescriptors = [sectionSortDescriptor]
            fetchRequest.sortDescriptors = sortDescriptors
            listOfPets = try context.fetch(fetchRequest)
            //try listOfPets = context.fetch(fetchRequest)
            
            
            return listOfPets
        }catch {
            return listOfPets
        }
    }
    
    class func fetchFilterData(userID: String) -> [PetEntity]? {
        let context = getContext()
        let fetchRequest:NSFetchRequest<PetEntity> = PetEntity.fetchRequest()
        var pet:[PetEntity]? = nil
                
        let predicate = NSPredicate(format: "userID = %@", userID)
        fetchRequest.predicate = predicate
        
        do {
            pet = try context.fetch(fetchRequest)
            return pet
            
        }catch {
            return pet
        }
    }
    
    class func deleteObject(pet: PetEntity) -> Bool {
        
        let context = getContext()
        context.delete(pet)
        
        do {
            try context.save()
            return true
        }catch {
            return false
        }
        
    }
    
    class func cleanDelete() -> Bool {
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: PetEntity.fetchRequest())
        
        do {
            try context.execute(delete)
            return true
        }catch {
            return false
        }
    }
    
    
    
    let URL_GET_TEAMS = URL(string: "https://serwer1878270.home.pl/WebService/api/getallpets.php")
    var petsArray:[Pet]? = []

    func get_data_from_url_old (_ link:String){
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
            
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let pets = json["pets"] as? [[String: Any]] {
                    for pet in pets {
                        let petObject:Pet = Pet()
                        
                        if let id = pet["ID"] as? Int                    {  petObject.ID = id  }
                        if let name = pet["Name"] as? String                {  petObject.Name = name  }
                        if let breed = pet["Breed"] as? String              {  petObject.Breed = breed  }
                        if let color = pet["Color"] as? String              {  petObject.Color = color  }
                        if let city = pet["City"] as? String                {  petObject.City = city  }
                        if let street = pet["Street"] as? String            {  petObject.Street = street  }
                        //                        if let petType = pet["PetType"] as? String          {  petObject.PetType = petType  }
                        if let description = pet["Description"] as? String  {  petObject.Description = description  }
                        if let lastDate = pet["LastDate"] as? String        {  petObject.LastDate = lastDate  }
                        if let longitude = pet["Longitude"] as? Double      {  petObject.Longitude = longitude  }
                        if let latitude = pet["Latitude"] as? Double        {  petObject.Latitude = latitude  }
                        //                        if let status = pet["Status"] as? String            {  petObject.Status = status  }
                        if let image = pet["Image"] as? String              {  petObject.Image = image  }
                        if let userID = pet["UserID"] as? Int               {  petObject.UserID = userID  }
                        if let uuid = pet["UUID"] as? String                {  petObject.UUID = uuid  }
                        //                        if let dateTimeModification = pet["DateTimeModification"] as? NSDate {  petObject.DateTimeModification = dateTimeModification  }
                        
                        //                        let pecik = Pet(ID: petObject.ID, Name: petObject.Name, Breed: petObject.Breed, Color: petObject.Color, City: petObject.City, Street: petObject.Street, PetType: "", Description: petObject.description, LastDate: petObject.LastDate, Longitude: petObject.Longitude, Latitude: petObject.Latitude, Status: "1", Image: petObject.Image, UserID: petObject.UserID, UUID: petObject.UUID, DateTimeModification: NSDate())
                        //
                        //                        let pecikCons = Pet(ID: 1, Name: "a", Breed: "b", Color: "c", City: "c", Street: "s", PetType: "", Description: "d", LastDate: "l", Longitude: 2, Latitude: 3, Status: "1", Image: "asd", UserID: 3, UUID: "asd", DateTimeModification: NSDate())
                        //
                        //                        self.petsArray?.append(pecik)
                        //                        self.petsArray?.append(pecikCons)
                        self.petsArray?.append(petObject)
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
            }
            
        }
        
        
        print(petsArray?.count ?? 0)
        
        
        
        //executing the task
        task.resume()
        
        
    }
    
   

}








