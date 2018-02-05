//
//  DataService.swift
//  PetAlert
//
//  Created by Mateusz Loska on 22/01/2018.
//  Copyright © 2018 petalert. All rights reserved.
//
import Foundation
import UIKit

class DataService {
    
    static let instance = DataService()
    
    // Temp data
    private let dogTempList =
    [
        Pet(ID: 1, Name: "mateusz", Breed: "mateusz", Color: "mateusz", City: "mateusz", Street: "mateusz", PetType: "mateusz", Description: "mateusz", LastDate: "mateusz", Longitude: 5.0, Latitude: 2.0, Status: "mateusz", Image: "1_kundel", ImageData: UIImage(named: "1_kundel")
            , UserID: 1, UUID: "mateusz", DateTimeModification: NSDate(), StatusLoc: 1),
        
        Pet(ID: 1, Name: "Iksra", Breed: "mateusz", Color: "mateusz", City: "mateusz", Street: "mateusz", PetType: "mateusz", Description: "mateusz", LastDate: "mateusz", Longitude: 5.0, Latitude: 2.0, Status: "mateusz", Image: "3_wilczur", ImageData: UIImage(named: "1_kundel")
            , UserID: 1, UUID: "mateusz", DateTimeModification: NSDate(), StatusLoc: 1)
    ]
    
    
    //  Receive methods - temp
    func getDogTempList() ->[Pet]
    {
        return dogTempList
    }
}
