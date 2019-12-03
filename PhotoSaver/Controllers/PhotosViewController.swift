//
//  PhotosViewController.swift
//  PhotoSaver
//
//  Created by Artjoms Vorona on 03/12/2019.
//  Copyright © 2019 Artjoms Vorona. All rights reserved.
//

import CoreData
import UIKit

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var savedPhotos = [Photos]()
    var managedObjectContext: NSManagedObjectContext?
    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        loadData()
    }
    
    //MARK: - IBactions
    @IBAction func openActionSheetTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Select photo source?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Use photo library", style: .default, handler: { (action) in
            print("Photo Galery")
            self.imagePicker.delegate = self
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Take a new photo", style: .default, handler: { (action) in
            print("Take a photo")
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera
                self.imagePicker.allowsEditing = true
                self.imagePicker.cameraCaptureMode = .photo
                self.imagePicker.modalPresentationStyle = .fullScreen
                
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                self.basicAlert(title: "Camera is not available", message: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            print("Dismiss")
        }))
        
        self.present(alert, animated: true) {
            print("Completed")
        }
    }//end action sheet
    
    //MARK: - Functions
    
    func loadData() {
        let request: NSFetchRequest<Photos> = Photos.fetchRequest()
        
        do {
            let result = try managedObjectContext?.fetch(request)
            savedPhotos = result!
            collectionView.reloadData()
        } catch  {
            fatalError("Error in retrieving Photo item")
        }
    }
    
    func pickedNewImage(with image: UIImage) {
        let pickedItem = Photos(context: managedObjectContext!)
        pickedItem.image = NSData(data: image.jpegData(compressionQuality: 0.3)!) as Data
        
        do {
            try self.managedObjectContext?.save()
            self.loadData()
        } catch  {
            fatalError("Could not save data")
        }
    }

}//end class

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil)
            self.pickedNewImage(with: pickedImage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotosCollectionViewCell else { return UICollectionViewCell() }
        
        let photo = savedPhotos[indexPath.row]
        print(photo.image as Any)
        
        let imageView: UIImageView = UIImageView(frame: CGRect(x: 5, y: 2, width: 190, height: 240))
        
        if let imageData = photo.value(forKey: "image") as? NSData {
            if let image = UIImage(data: imageData as Data) {
                imageView.image = image
                cell.contentView.addSubview(imageView)
            }
        }
        
        return cell
    }
    
}


