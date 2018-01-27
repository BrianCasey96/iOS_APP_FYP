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
        
        photosCollection.delegate = self
        photosCollection.dataSource = self
        images.append(UIImage(named: "Hey")!)
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
        
        guard let cell = photosCollection.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CollectionViewCell.")
        }
        
        cell.string.text = "Image \(indexPath.row+1)"
        let image : UIImage = images[indexPath.row]
        
        cell.img.image = image
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //     var cell : UICollectionViewCell = photosCollection.cellForItem(at: indexPath)!
        
        let imaged : UIImage = images[indexPath.row]
        
        let newImageView = UIImageView(image: imaged)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        newImageView.addGestureRecognizer(pan)
        //
        
        //        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        //        newImageView.addGestureRecognizer(tap)
        //
        self.view.addSubview(newImageView)
        
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        print("hello")
        let translation = sender.translation(in: self.view)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        
        if sender.state == .ended{
            sender.view?.removeFromSuperview()
        }
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func getAlert(_ sender: Any) {
        
        let myalert = UIAlertController(title: "Insert Picture", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        myalert.addAction(UIAlertAction(title: "From Library", style: .default) { (action:UIAlertAction!) in
            self.openLibrary()
        })
        
        myalert.addAction(UIAlertAction(title: "Take Picture", style: .default) { (action:UIAlertAction!) in
            self.openCamera()
        })
        
        
        myalert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
        })
        
        self.present(myalert, animated: true)
    }

    
    func openLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openCamera() {
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        images.append(image)
        dismiss(animated:true, completion: nil)
        photosCollection.reloadData()
    }
}


