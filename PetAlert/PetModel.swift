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

