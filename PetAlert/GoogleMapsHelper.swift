//
//  GoogleMapsHelper.swift
//  PetAlert
//
//  Created by Claudia on 28.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import Foundation
import GoogleMaps


func getAddressBasedOnTheMarker (marker: GMSMarker, completion: @escaping (_ street: String, _ city: String, _ placeString: String) -> Void) -> (){
    let geocoder = GMSGeocoder()
    var streetValue = ""
    var cityValue = ""
    var placeStringValue = ""
    
    geocoder.reverseGeocodeCoordinate(marker.position) { response, error in
        if let location = response?.firstResult() {
            let lines = location.lines! as [String]
            let value = lines.joined(separator: "\n")
            streetValue = lines[0]
            cityValue = lines[1].components(separatedBy: ",")[0]
            placeStringValue = value
            completion(streetValue, cityValue, placeStringValue)
        }
    }
    
    // OLD VERSION, bad due to the async. used competion in that place. left for remembering
    //  return (street: streetValue, city: cityValue, placeString: placeStringValue)
    
    // OLD VERSION usage:
    //        let getAddressBasedOnTheMarkerResults = getAddressBasedOnTheMarker(marker: finalMarker) {}
    //        street = getAddressBasedOnTheMarkerResults.street
    //        city = getAddressBasedOnTheMarkerResults.city
    //        lastSeenPlaceLbl.text = getAddressBasedOnTheMarkerResults.placeString
}
