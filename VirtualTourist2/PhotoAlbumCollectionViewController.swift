//
//  PhotoAlbumCollectionViewController.swift
//  VirtualTourist2
//
//  Created by Joshua Schindler on 5/6/18.
//  Copyright © 2018 Joshua Schindler. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var image: UIImage!
    var intCount: Int = 0
    var iPicturesDownloaded: Int = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataController:DataController!
    var pin:Pins!
    var images_cache = [String:UIImage]()
    var bolisLocal = true
    var arrayOfImages = [String]()
    var arrayofPhotos: [Photos]! = []
    var selectedLatitude: Double = 0
    var selectedLongtitude: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        getPhotos()
    }
    
    @IBAction func refreshPhotos(_ sender: Any) {
        
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pins == %@", pin)
        fetchRequest.predicate = predicate
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try dataController.viewContext.execute(deleteRequest)
        } catch let error as NSError {
            let alert = UIAlertController(title: "Alert", message: "There was a problem deleting youe existing photos!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        getPhotos()
    }
    
    @IBAction func goBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func getPhotos() {
        debugPrint("getPhotos")
        //if there are already pictures downloaded for this pin display them
        let fetchRequest:NSFetchRequest<Photos> = Photos.fetchRequest()
        let predicate = NSPredicate(format: "pins == %@", pin)
        fetchRequest.predicate = predicate
        if let result = try? dataController.viewContext.fetch(fetchRequest)
        {
            arrayofPhotos = result
            intCount = arrayofPhotos.count
            print("Pictures returned from memory: \(intCount)")
        }
        //else get new pictures from Flickr
        if arrayofPhotos.count < 1 {
            print("need to get pictures from Flickr")
            bolisLocal = false
            let _ = SIClient.sharedInstance.getPics(passedLatitude: selectedLatitude, passedLongitude: selectedLongtitude) { (data, error) in
                if error == nil {
                    self.arrayOfImages = data
                    self.intCount = self.arrayOfImages.count
                    print("Pictures returned from Flickr: \(self.intCount)")
                    performUIUpdatesOnMain {
                        self.collectionView.reloadData()
                    }
                } else {
                    let alert = UIAlertController(title: "Alert", message: "There was a problem getting photos from Flickr!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return intCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CustomCollectionViewCell
        //display from flickr after download is complete
        if bolisLocal == false {
            cell.imageView.image = nil
            cell.imageView.image = UIImage(named: "loading")
            DispatchQueue.global(qos: .userInitiated).async {
                self.getImage(imageURL: self.arrayOfImages[indexPath.row])
                DispatchQueue.main.async {
                    cell.imageView.image = self.image
                    let photo = Photos(context: self.dataController.viewContext)
                    photo.photo = UIImageJPEGRepresentation(self.image, 0)! as NSData
                    photo.pins = self.pin!
                    try? self.dataController.viewContext.save()
                    self.arrayofPhotos.append(photo)
                }
            }
        } else { //display from memory
            cell.imageView.image = UIImage(data: arrayofPhotos[indexPath.row].photo! as Data)
        }
        return cell
    }
    
    func getImage(imageURL:String) {
        print("getImage")
        let imageURL2 = URL(string: imageURL)
        if let imageData = try? Data(contentsOf: imageURL2!) {
            self.image = UIImage(data: imageData)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pictureToDelete = arrayofPhotos[indexPath.row]
        dataController.viewContext.delete(pictureToDelete)
        try? dataController.viewContext.save()
        arrayofPhotos.remove(at: indexPath.row)
        intCount = intCount - 1
        collectionView.deleteItems(at: [indexPath])
    }
}
