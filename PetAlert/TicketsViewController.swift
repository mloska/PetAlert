//
//  SecondViewController.swift
//  PetAlert
//
//  Created by Claudia on 06.01.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit
import RealmSwift

class TicketsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var pets:[Pet]? = []
    var refreshControl: UIRefreshControl!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let loggedUserID = UserDefaults.standard.value(forKey: "logged_user_ID")

    //Web service url
    let URL_GET_PETS_STR = "https://serwer1878270.home.pl/WebService/api/getallpetsforuser.php?userID="

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // establish connection for passing link and fire the main function
        connectToJson(link: URL_GET_PETS_STR + "\(loggedUserID ?? "-1")", mainFunctionName: mainTicketsFunction)
        print (URL_GET_PETS_STR + "\(loggedUserID ?? "-1")")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        tableView.addGestureRecognizer(gesture)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func mainTicketsFunction (passedJsonArray: [[String: Any]]) {
        // return to main array for this controller results from choped json into single objects in array
        self.pets = JsonToArray(inputJsonArray: passedJsonArray)
        self.tableView.reloadData()
    }
    
    @objc func refresh(_ sender: Any) {
        connectToJson(link: URL_GET_PETS_STR + "\(loggedUserID ?? "-1")", mainFunctionName: mainTicketsFunction)
        refreshControl.endRefreshing()
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell
        
        cell.cellView.layer.cornerRadius = cell.cellView.frame.height / 2
        cell.cellImage.layer.cornerRadius = cell.cellImage.frame.height / 2
        
        let petObject = pets![indexPath.row]

        cell.cellTitle.text = "\(petObject.Color ?? "") \(petObject.Breed ?? "")" + " (" +  "\(petObject.Name ?? "")" + ")"
        cell.cellSubtitle.text = "\(petObject.Street ?? ""), \(petObject.City ?? "")"
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
        performSegue(withIdentifier: "showNewTicketDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsTicketViewController {
            let counter = tableView.indexPathForSelectedRow?.row
            let petObject = pets![counter!]
            destination.destPet = petObject
        }
    }
    
    //swipe on the left side
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Edit")
            success(true)
        })
        editAction.image = UIImage(named: "icon_edit")
        editAction.backgroundColor = .purple
        
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let petObject = self.pets![indexPath.row]
            print("Before deleting: ", self.pets?.count ?? 0)
            // TODO
//            if CoreDataHelper.deleteObject(pet: petObject) {
//                print("After deleting: ", self.pets?.count ?? 0)
//                print("OK, marked as Delete")
//                success(true)
//                self.pets = CoreDataHelper.fetchFilterData(userID: "21")
//                tableView.reloadData()
//            } else {
//                print("NOK, something went wrong with marking as Delete")
//                success(false)
//                tableView.reloadData()
//            }
            
            
        })
        deleteAction.image = UIImage(named: "icon_trash")
        deleteAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        
    }
    
    //swipe on the right side
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let spottedAction = UIContextualAction(style: .normal, title:  "Spotted", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Spotted")
            let petObject = self.pets![indexPath.row]
            petObject.setValue("Spotted", forKey: "status")
            petObject.setValue(NSDate(), forKey: "dateTimeModification")
            // TODO
//            do{
//                try self.managedContext.save()
//            }
//            catch
//            {
//                print(error)
//            }
//            self.pets = CoreDataHelper.fetchFilterData(userID: "21")
            tableView.reloadData()
            success(true)
        })
        spottedAction.image = UIImage(named: "icon_marker")
        spottedAction.backgroundColor = .blue
        
        let foundAction = UIContextualAction(style: .normal, title:  "Found", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            print("OK, marked as Found")
            let petObject = self.pets![indexPath.row]
            petObject.setValue("Found", forKey: "status")
            petObject.setValue(NSDate(), forKey: "dateTimeModification")
            // TODO
//            do{
//                try self.managedContext.save()
//            }
//            catch
//            {
//                print(error)
//            }
//            self.pets = CoreDataHelper.fetchFilterData(userID: "21")
            tableView.reloadData()
            success(true)
        })
        foundAction.image = UIImage(named: "icon_tick")
        foundAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [spottedAction, foundAction])
    }



}

