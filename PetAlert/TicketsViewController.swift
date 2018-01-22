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

    var pets:[PetEntity]? = nil
    var refreshControl: UIRefreshControl!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pets = CoreDataHelper.fetchFilterData(userID: "21")
        print(pets?.count ?? 0)
        
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
    
    @objc func refresh(_ sender: Any) {
        pets = CoreDataHelper.fetchFilterData(userID: "21")
        tableView.reloadData()
        print("reloaded, counted pets:", pets?.count ?? 0)
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
        let petColor = petObject.value(forKey: "color")
        let petBreed = petObject.value(forKey: "breed")
        let petName = petObject.value(forKey: "name")
        let petStreet = petObject.value(forKey: "street")
        let petCity = petObject.value(forKey: "city")
        let petImageBinary = petObject.value(forKey: "imageBinary") ?? NSData()
        let petStatus = petObject.value(forKey: "status") as? String ?? ""
        
        cell.cellTitle.text = "\(petColor ?? "") \(petBreed ?? "")" + " (" +  "\(petName ?? "")" + ")"
        cell.cellSubtitle.text = "\(petStreet ?? ""), \(petCity ?? "")"
        cell.cellImage.image = UIImage(data: petImageBinary as! Data)
        
        if (petStatus == "Searching") {
            cell.cellView.backgroundColor = .green
        }
        else if (petStatus == "Found") {
            cell.cellView.backgroundColor = .purple
            cell.cellTitle.textColor = .red
            cell.cellSubtitle.textColor = .red
        }
        else if (petStatus == "Spotted") {
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
        pets = CoreDataHelper.fetchObject()
        
        if let destination = segue.destination as? DetailsTicketViewController {
            
            let counter = tableView.indexPathForSelectedRow?.row
            let petObject = pets![counter!]
            
            //destination.destPet = petObject
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
            
            if CoreDataHelper.deleteObject(pet: petObject) {
                print("After deleting: ", self.pets?.count ?? 0)
                print("OK, marked as Delete")
                success(true)
                self.pets = CoreDataHelper.fetchFilterData(userID: "21")
                tableView.reloadData()
            } else {
                print("NOK, something went wrong with marking as Delete")
                success(false)
                tableView.reloadData()
            }
            
            
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
            do{
                try self.managedContext.save()
            }
            catch
            {
                print(error)
            }
            self.pets = CoreDataHelper.fetchFilterData(userID: "21")
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
            do{
                try self.managedContext.save()
            }
            catch
            {
                print(error)
            }
            self.pets = CoreDataHelper.fetchFilterData(userID: "21")
            tableView.reloadData()
            success(true)
        })
        foundAction.image = UIImage(named: "icon_tick")
        foundAction.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [spottedAction, foundAction])
    }



}

