//
//  CreateNewTicketViewController.swift
//  PetAlert
//
//  Created by Claudia on 10.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData

class CreateNewTicketViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, GMSMapViewDelegate {

    var pets:[Pet]? = []
    
    //URL to web service
    let URL_SAVE_PET = "https://serwer1878270.home.pl/WebService/api/createpet.php"
    let URL_UPLOAD_PHOTO = "https://serwer1878270.home.pl/WebService/api/uploadImage.php"

    
    
    // inputs from storyboard
    @IBOutlet weak var nameInput: UITextField!
    @IBOutlet weak var breedInput: UITextField!
    @IBOutlet weak var colorInput: UITextField!
    @IBOutlet weak var imageCtr: UIImageView!
    
    // status choice from picker
    @IBOutlet weak var statusInput: UITextField!
    let statuses = ["Found", "Searching"]
    var selectedStatus:String = ""

    
    // Google maps
    @IBOutlet weak var lastSeenPlaceLbl: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var street:String = ""
    var city:String = ""
    var finalLongitude:Double = 0.0
    var finalLatitude:Double = 0.0
    var finalMarker:GMSMarker = GMSMarker()
    
    // Date Time picker
    @IBOutlet weak var lastSeenDateInput: UITextField!
    var fullDateTimeValue:String = ""
    let picker = UIDatePicker()
    
    // Photo
    var imageData:NSData! = NSData()

    
    
    // ************** Choose photo
    
    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Choose photo", message: "Message choose photo", preferredStyle: .actionSheet)
        
        // TODO: add icons for the choices
        //let imageCamera = UIImage(named: "icon_camera")
        
        let choiceCamera = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.showPicker(sourceType: .camera)
        })
        let choiceAlbum = UIAlertAction(title: "Album", style: .default, handler: { (action) in
            self.showPicker(sourceType: .photoLibrary)
        })
        let choiceCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        //choiceCamera.setValue(imageCamera, forKey: "imageCamera")
        
        alertController.addAction(choiceCamera)
        alertController.addAction(choiceAlbum)
        alertController.addAction(choiceCancel)
        present(alertController, animated: true, completion: nil)
    }
    
    // Show image picker
    func showPicker (sourceType: UIImagePickerControllerSourceType){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        self.present(picker, animated: true, completion: nil)
    }

    // Cancel the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Chosen image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedPhoto = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageCtr.image = selectedPhoto
        imageData = UIImagePNGRepresentation(selectedPhoto)! as NSData
        //let compressedImage = UIImage(data: imageData!)
        //UIImageWriteToSavedPhotosAlbum(selectedPhoto, nil, nil, nil)
        
        
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    // ************** Last date time picker

    func createDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        lastSeenDateInput.inputAccessoryView = toolbar
        lastSeenDateInput.inputView = picker
        
        // format picker for date
        picker.datePickerMode = .dateAndTime
        picker.locale = NSLocale(localeIdentifier: "pl_PL") as Locale
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "dd.MM.yyyy HH:mm"

        let dateString = formatter.string(from: picker.date)

        lastSeenDateInput.text = "\(dateString)"
        fullDateTimeValue = dateString
        
        self.view.endEditing(true)
    }
    
    
    // ************** Google Maps

    func initializeTheLocationManager()
    {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locationManager.location?.coordinate
        let coordinate = CLLocationCoordinate2DMake(Double((location?.latitude)!), Double((location?.longitude)!))
        let marker = GMSMarker(position: coordinate)
        self.mapView.clear()
        marker.isDraggable = true
        marker.position = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude)
        marker.map = self.mapView
        self.mapView.animate(toLocation: coordinate)
        finalMarker = marker
        
        cameraMoveToLocation(toLocation: location)
        self.mapView.animate(toLocation: coordinate)
        self.finalLongitude = coordinate.longitude
        self.finalLatitude = coordinate.latitude
        
        getAddressBasedOnTheMarker(marker: finalMarker)
        
    }

//    func mapView(_ mapView: GMSMapView, didDrag finalmarker: GMSMarker) {
//        print("Drag")
//    }
//
//    internal func mapView(_ mapView: GMSMapView, didBeginDragging marker: GMSMarker) {
//        print("didBeginDragging")
//    }
    
    internal func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging")
        getAddressBasedOnTheMarker(marker: marker)

    }

    func getAddressBasedOnTheMarker (marker: GMSMarker){
        let geocoder = GMSGeocoder()

        geocoder.reverseGeocodeCoordinate(marker.position) { response, error in
            if let location = response?.firstResult() {
                //let marker = GMSMarker(position: marker.coordinate)
                marker.isDraggable = true
                let lines = location.lines! as [String]
                let value = lines.joined(separator: "\n")
                self.street = lines[0]
                self.city = lines[1].components(separatedBy: ",")[0]
                self.lastSeenPlaceLbl.text = value
            }
        }
    }


   
    
    
    func cameraMoveToLocation(toLocation: CLLocationCoordinate2D?) {
        if toLocation != nil {
            mapView.camera = GMSCameraPosition.camera(withTarget: toLocation!, zoom: 15)
        }
    }
    
    
    // ************** Status picker
    
    func createStatusPicker(){
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusInput.inputView = statusPicker
        statusPicker.backgroundColor = .white
    }
    
    func createToolbar(){
        let toolbarStatus = UIToolbar()
        toolbarStatus.sizeToFit()
        
        // done button for toolbar
        let doneStatus = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dissmissKeyboard))
        toolbarStatus.setItems([doneStatus], animated: false)
        toolbarStatus.isUserInteractionEnabled = true
        statusInput.inputAccessoryView = toolbarStatus
    }
    
    @objc func dissmissKeyboard(){
        view.endEditing(true)
        if (selectedStatus == ""){
            selectedStatus = statuses[0]
        }
        statusInput.text = selectedStatus
    }
    
    // Status picker components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Status picker rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statuses.count
    }
    
    // Status picker displayed values
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statuses[row]
    }
    
    // Status picker selection action
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStatus = statuses[row]
        statusInput.text = selectedStatus
    }
    

    // ************** Save button and main object creation

    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let loggedUserID = UserDefaults.standard.value(forKey: "logged_user_ID")
        let imageNameStr:String = ""
        

//        var addedPet:Pet = Pet(ID: 0, Name: nameInput.text, Breed: breedInput.text, Color: colorInput.text, City: city, Street: street, PetType: "1", Description: "", LastDate: lastSeenDateInput.text, Longitude: finalLongitude, Latitude: finalLatitude, Status: selectedStatus, Image: imageNameStr, ImageData: UIImage(), UserID: loggedUserID as? Int, UUID: UUID().uuidString, DateTimeModification: NSDate())
        
        
        //created NSURL
        let requestURL = NSURL(string: URL_SAVE_PET)
        
        //creating NSMutableURLRequest
        let request = NSMutableURLRequest(url: requestURL! as URL)
        
        //setting the method to post
        request.httpMethod = "POST"
        
        //getting values from text fields
        let name = nameInput.text
        let breed = breedInput.text
        let color = colorInput.text
        let city = self.city
        let street = self.street
        let petType = "1"
        let description = ""
        let lastDate = picker.date
        let longitude = finalLongitude
        let latitude = finalLatitude
        var status = selectedStatus
        let image = imageNameStr
        //let imageData = UIImage()
        let userID = "\(loggedUserID ?? "0")"
        let uuid = UUID().uuidString
        let dateTimeModification = NSDate()
        
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateTimeModificationString = formatter.string(from: dateTimeModification as Date)
        let lastDateString = formatter.string(from: lastDate as Date)

        if (status == "Searching"){
            status = "1"
        } else if (status == "Spotted"){
            status = "2"
        } else if (status == "Found"){
            status = "3"
        } else {
            status = "0"
        }
        
        //creating the post parameter by concatenating the keys and values from text field
        var postParameters = "name="+name!
        postParameters+="&breed="+breed!
        postParameters+="&color="+color!
        postParameters+="&city="+city
        postParameters+="&street="+street
        postParameters+="&petType="+petType
        postParameters+="&description="+description
        postParameters+="&lastDate="+String(lastDateString)
        postParameters+="&longitude="+String(longitude)
        postParameters+="&latitude="+String(latitude)
        postParameters+="&status="+status
        postParameters+="&image="+image
        postParameters+="&userID="+userID
        postParameters+="&uuid="+uuid
        postParameters+="&dateTimeModification="+dateTimeModificationString
        //adding the parameters to request body
        request.httpBody = postParameters.data(using: String.Encoding.utf8)
        
        
        //creating a task to send the post request
        let task = URLSession.shared.dataTask(with: request as URLRequest){
            data, response, error in
            
            if error != nil{
                print("error is \(String(describing: error))")
                return;
            }
            
            //parsing the response
            do {
                //converting resonse to NSDictionary
                let myJSON =  try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                
                //parsing the json
                if let parseJSON = myJSON {
                    
                    //creating a string
                    var msg : String!
                    
                    //getting the json response
                    msg = parseJSON["message"] as! String?
                    
                    //printing the response
                    print(msg)
                    
//                    self.myImageUploadRequest(urlUploadPhoto: self.URL_UPLOAD_PHOTO, myImageView: self.imageCtr)
                    
                }
            } catch {
                print(error)
            }
            
        }
        //executing the task
        task.resume()
        
        
        
        
        
        // upload photo
        myImageUploadRequest(urlUploadPhoto: URL_UPLOAD_PHOTO, myImage: imageCtr.image!, uuidParam: uuid, thumbnailMode: false)
        
        let imageData = UIImagePNGRepresentation(imageCtr.image!)!
        let options = [
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 300] as CFDictionary
        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        let imageReference = CGImageSourceCreateThumbnailAtIndex(source, 0, options)!
        let thumbnail = UIImage(cgImage: imageReference)
        
        myImageUploadRequest(urlUploadPhoto: URL_UPLOAD_PHOTO, myImage: thumbnail, uuidParam: uuid, thumbnailMode: true)

        
        
        print("Dodano")
//        pets = CoreDataHelper.fetchObject()
        
        let alert = UIAlertController(title: "Saved", message: "Your ticket has been saved", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//            let vc = storyboard.instantiateViewController(withIdentifier: "NewView")
//
//            self.navigationController?.pushViewController(vc, animated: true)

            
            let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "TicketsViewController")
            let navController = UINavigationController(rootViewController: VC1)
            self.present(navController, animated:true, completion: nil)

//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let rootVC = storyboard.instantiateViewController(withIdentifier: "AddTicketViewController") as! UINavigationController
//            let playVC = storyboard.instantiateViewController(withIdentifier: "TicketsViewController")
//            window?.rootViewController?.presentViewController(rootVC, animated: true, completion: { () -> Void in
//                rootVC.pushViewController(playVC, animated: true)
//            })
            
            //let viewControllerYouWantToPresent = self.storyboard?.instantiateViewController(withIdentifier: "TicketsViewController")
            //self.present(viewControllerYouWantToPresent!, animated: true, completion: nil)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)

    }
    
    // ************** ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        createDatePicker()
        createStatusPicker()
        createToolbar()
        initializeTheLocationManager()
        self.mapView.isMyLocationEnabled = true
    }
    
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    
    func myImageUploadRequest(urlUploadPhoto: String, myImage: UIImage, uuidParam: String, thumbnailMode: Bool)
    {
        let loggedUserID = UserDefaults.standard.value(forKey: "logged_user_ID")
        let myUrl = NSURL(string: urlUploadPhoto);
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "uuidName"  : "\(uuidParam)",
            "userId"    : "\(loggedUserID ?? "0")"
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(myImage, 0.1)
        
        if(imageData==nil)  { return; }
        
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary, imageName: uuidParam, thumbnail: thumbnailMode ? true : false) as Data
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error ?? "" as! Error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                print(json ?? "")
                
                DispatchQueue.main.sync(execute: {
                    
                    //myImage = nil;
                    
                })
                
                
                
            }catch
            {
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String, imageName: String, thumbnail: Bool) -> NSData {
        let body = NSMutableData();
        
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
            }
        }
        
        var filename = "\(imageName).jpg"
        if (thumbnail){
            filename="thumbnail_" + "\(filename)"
        }
        let mimetype = "image/jpg"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageDataKey as Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }

}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}



