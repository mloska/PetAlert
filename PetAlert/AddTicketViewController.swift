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
    
    //Web service url
    let URL_GET_PETS_STR = "https://serwer1878270.home.pl/WebService/api/getallpets.php"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // establish connection for passing link and fire the main function
        connectToJson(link: URL_GET_PETS_STR, mainFunctionName: mainAddTicketFunction)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        tableView.addGestureRecognizer(gesture)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

    }
    
    func mainAddTicketFunction (passedJsonArray: [[String: Any]]) {
        // return to main array for this controller results from choped json into single objects in array
        self.petsArray = JsonToArray(inputJsonArray: passedJsonArray, downloadThumbnail: true)

        self.tableView.reloadData()
    }
    
    @objc func refresh(_ sender: Any) {
        connectToJson(link: URL_GET_PETS_STR, mainFunctionName: mainAddTicketFunction)
        refreshControl.endRefreshing()
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = false
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


