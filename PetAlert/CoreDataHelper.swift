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
    
   

}








