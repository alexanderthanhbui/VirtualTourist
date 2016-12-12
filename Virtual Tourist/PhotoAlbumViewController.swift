//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Hayne Park on 11/18/16.
//  Copyright © 2016 Alexander Bui. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    //Properties:
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    let annotation = MKPointAnnotation()
    var tappedPin: Pin!
    
    lazy var sharedContext: NSManagedObjectContext = {
        // Get the stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let stack = delegate.stack
        return stack.context
    }()
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var bottomButton: UIBarButtonItem!
    @IBAction func newCollectionButton(_ sender: AnyObject) {
        
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
        } else {
            deleteSelectedPhotos()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.isHidden = false
        
        fetchedResultsController.delegate = self
        
        annotation.coordinate.latitude = tappedPin?.latitude as Double!
        annotation.coordinate.longitude = tappedPin?.longitude as Double!
        
        mapView.delegate = self
        mapView.addAnnotation(annotation)
        
        centerMapOnLocation(annotation, regionRadius: 500.0)
        
        //load saved pins
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error")
        }
        
        updateBottomButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if fetchedResultsController.fetchedObjects?.count == 0 {
            loadPhotoAlbum()
        } else {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        let width = floor(self.collectionView.frame.size.width/3)
        flowLayout.itemSize = CGSize(width: width, height: width)
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    // MARK: Button Helper methods
    func updateBottomButton() {
        if selectedIndexes.count > 0 {
            bottomButton.title = "Remove Selected Photos"
        } else {
            bottomButton.title = "New Collection"
        }
    }
    
    func loadPhotoAlbum() {
        
        // Get images from Flickr client
        Client.sharedInstance().getPagesFromFlickrBySearch(Double((tappedPin.latitude)), longitude: Double((tappedPin.longitude)), completionHandlerForFlickrPages:  { (randomPageNumber, error) in
            if let randomPageNumber = randomPageNumber {
                Client.sharedInstance().displayImagesFromFlickrBySearch(Double((self.tappedPin.latitude)), longitude: Double((self.tappedPin.longitude)), withPageNumber: randomPageNumber, completionHandlerForFlickrImages: { (photos, error) in
                    if let photos = photos {

                        performUIUpdatesOnMain {
                            _ = photos.map() { (dictionary: [String: AnyObject]) -> Photo in
                                let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                                photo.pinData = self.tappedPin
                                self.saveToBothContexts()
                                return photo
                            }
                        }
                        
                    } else {
                        print("Error: \(error)")
                    }
                })
            } else {
                print("Error: \(error)")
            }
        })
    }
    
    //MARK: Collection View Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    // MARK: - Configure Cell
    
    func configureCell(_ cell: CustomCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        var photoImage = UIImage(named: "VirtualTourist_512")
        
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        
        // Set the Flickr Image
        if photo.imagePath == nil || photo.imagePath == "" {
            photoImage = UIImage(named: "VirtualTourist_512")!
            
        } else if photo.imageData != nil {
            //Loads images from saved Core Data if picture content exists
            photoImage = UIImage(data: photo.imageData! as Data)
            
        } else {
            
            // Start the task that will eventually download the image
            let task = Client.sharedInstance().getFlickrImage(Client.Constants.Flickr.imageSize, filePath: photo.imagePath!, completionHandlerForImage: { (imageData, error) in
                
                if let error = error {
                photoImage = UIImage(named: "placeholderImageCamera-300px.png")
                    performUIUpdatesOnMain {
                    cell.imageView.image = photoImage
                    }
                }
                                                                        
                if let data = imageData {
                // Create the image
                photoImage = UIImage(data: data)!
                                                                            
                // save in Core Data
                photo.imageData = data as NSData?
                self.saveToBothContexts()
                                                                            
                // update the cell later, on the main thread
                    performUIUpdatesOnMain {
                    cell.imageView!.image = photoImage
                    }
                }
            })
        }
        
        cell.imageView!.image = photoImage
        
        // If the cell is "selected" it's color panel is grayed out
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.alpha = 0.5
        } else {
            cell.alpha = 1.0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CustomCollectionViewCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
        updateBottomButton()
    }
    
    // MARK: Save to Both Contexts function
    func saveToBothContexts() {
        // Save pin data to both contexts
        let stack = (UIApplication.shared.delegate as! AppDelegate).stack
        stack.saveContexts()
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    //Centers the map on a coordinate (with lat and lon) with requisite radius
    func centerMapOnLocation(_ location: MKPointAnnotation, regionRadius: Double) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // MARK: NSFetchedResultsController Methods
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "imageID", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "pinData == %@", self.tappedPin!)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
        
    }()
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
            
        case .insert:
            print("Insert an item")
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Delete an item")
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            print("Update an item.")
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
            }, completion: nil)
    }
    
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.delete(photo)
        }
        print("deleting all photos")
        
        saveToBothContexts()
        loadPhotoAlbum()
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.object(at: indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            sharedContext.delete(photo)
            print("deleting selected photos")
        }
        
        selectedIndexes.removeAll()
        saveToBothContexts()
    }
}
