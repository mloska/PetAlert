//
//  HistoryListTicketViewController.swift
//  PetAlert
//
//  Created by Claudia on 06.02.2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

class HistoryListTicketViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var pets:[Pet]? = []
    var sentPetToViewHistory = Pet()
    var refreshControl: UIRefreshControl!

    @IBOutlet weak var tableView: UITableView!
    let URL_GET_PETS_HISTORY = "https://serwer1878270.home.pl/WebService/api/gethistoryticketlist.php?uuid="


    override func viewDidLoad() {
        super.viewDidLoad()
        let uuid = sentPetToViewHistory.UUID
        connectToJson(link: URL_GET_PETS_HISTORY + "\(uuid ?? "")", mainFunctionName: mainHistoryListTicketsFunction)

        tableView.delegate = self
        tableView.dataSource = self
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(dismiss(fromGesture:)))
        tableView.addGestureRecognizer(gesture)
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
    }
    
    @objc func dismiss(fromGesture gesture: UISwipeGestureRecognizer) {
    }

    @objc func refresh(_ sender: Any) {
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }

    func mainHistoryListTicketsFunction (passedJsonArray: [[String: Any]]) {
        // return to main array for this controller results from choped json into single objects in array
        self.pets = JsonToArray(inputJsonArray: passedJsonArray, downloadThumbnail: true, downloadWithImages: false)
        self.tableView.reloadData()

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell") as! HistoryTicketTableViewCell
        
        let petObject = pets![indexPath.row]
        
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let DateTimeModification = formatter.string(from: petObject.DateTimeModification! as Date)
        var stan = ""
        var tick = ""
        
        if (petObject.Status == "Searching"){
            cell.imageHist.image = #imageLiteral(resourceName: "icon_searching")
            stan = "zaginął"
            tick = "utworzył"
        } else if (petObject.Status == "Spotted"){
            cell.imageHist.image = #imageLiteral(resourceName: "icon_spotted")
            stan = "został zauważony"
            tick = "zaktualizował"
        } else if (petObject.Status == "Found"){
            cell.imageHist.image = #imageLiteral(resourceName: "icon_found")
            stan = "został znaleziony"
            tick = "zamknął"
        }
        
        let desc = """
        Użytkownik \(petObject.UserID ?? 0)
        \(tick) zgłoszenie \(DateTimeModification)
        o psie, który \(stan) \(petObject.LastDate ?? "")
        w mieście \(petObject.City ?? "")
        na \(petObject.Street ?? "")
        """
        
        cell.descriptionLbl.text = desc
        
       
        
        return cell
    }


}
