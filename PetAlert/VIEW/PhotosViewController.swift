//
//  PhotosViewController.swift
//  PetAlert
//
//  Created by Mateusz Loska on 18/01/2018.
//  Copyright © 2018 petalert. All rights reserved.
//

import UIKit

private let reuseIdentifier = "myCell"

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
   
    
    @IBOutlet weak var dogsCollection:UICollectionView!;
    
    var dogs = [Pet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dogs = DataService.instance.getDogTempList()
        dogsCollection.dataSource = self
        dogsCollection.delegate  = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dogs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as? PhotoViewCell {
                let dog = dogs[indexPath.row]
            cell.updateViews(pet: dog)
            return cell
        }
        return PhotoViewCell()
        
    }
    
   func initDogs ()
   {
    
    }
}
