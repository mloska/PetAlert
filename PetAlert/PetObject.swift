//
//  PetObject.swift
//  PetAlert
//
//  Created by Claudia on 14.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import Foundation
import RealmSwift

class PetObejct : Object{
//    var Name:           String
//    var Breed:          String?
//    var Color:          String?
//    var City:           String
//    var Street:         String
//    var Status:         String
//    var PetType:        String?
//    var Description:    String?
//    var LastDate:       String
//    var Longitude:      Double = 0.0
//    var Latitude:       Double  = 0.0
//    var UUID:           String
//    var Image:          NSData?
//    var DateTimeModification:  NSDate
    
//    // Exmple:
//    let score = RealmOptional<Int>()
//    self.score.value = score
    
    @objc dynamic var Name: String = ""
    @objc dynamic var Breed: String? = ""
    @objc dynamic var Color: String? = ""
    @objc dynamic var City: String = ""
    @objc dynamic var Street: String = ""
    @objc dynamic var Status: String = ""
    @objc dynamic var PetType: String? = ""
    @objc dynamic var Description: String? = ""
    @objc dynamic var LastDate: String = ""
    @objc dynamic var Longitude: Double = 0.0
    @objc dynamic var Latitude: Double = 0.0
    @objc dynamic var UUID: String = ""
    @objc dynamic var Image: NSData? = NSData()
    @objc dynamic var DateTimeModification: NSDate = NSDate()
    
    convenience init(Name: String, Breed: String?, Color: String?, City: String, Street: String, Status: String, PetType: String?, Description: String?, LastDate: String, Longitude: Double, Latitude: Double, UUID: String, Image: NSData?, DateTimeModification: NSDate){
        self.init()
        self.Name = Name
        self.Breed = Breed
        self.Color = Color
        self.City = City
        self.Street = Street
        self.Status = Status
        self.PetType = PetType
        self.Description = Description
        self.LastDate = LastDate
        self.Longitude = Longitude
        self.Latitude = Latitude
        self.UUID = UUID
        self.Image = Image
    }
}
