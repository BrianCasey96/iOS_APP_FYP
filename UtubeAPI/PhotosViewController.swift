//
//  PhotosView.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 25/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate {
   
    var images : [UIImage] = []
    
    @IBOutlet var photosCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosCollection.reloadData()
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
      //  photosCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "CollectionViewCell"
        
        let cell = self.photosCollection.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionViewCell;
        
        //let imageview : UIImageView? = nil
       
        let image : UIImage = images[indexPath.row]
        
        //imageview?.image = image
    //    img.image = image
        // self.view.addSubview(imageview)
  //      cell?.contentView.addSubview(img)
        return cell!
    }

    
    @IBAction func openLibrary(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
   
    @IBAction func openCamera(_ sender: UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            var imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        images.append(image)
     //   img.image = image
        dismiss(animated:true, completion: nil)
    }
}
