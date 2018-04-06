//
//  PhotosView.swift
//  PlantApp
//
//  Created by Casey, Brian on 25/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit
import AVFoundation

class PhotosViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate{
    
    //  var images : [UIImage] = []
    var inPath : IndexPath? = nil
    var canDelete = false
    var images = [[UIImage: String]]()
    let fileManager = FileManager.default
    var result: String?
    
    let date = Date()
    let formatter = DateFormatter()
    
    @IBOutlet var photosCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.alpha = 0.9
        backgroundImage.image = UIImage(named: "leaves.png")
        
        photosCollection.backgroundView = backgroundImage
        
        getImages()
        photosCollection.delegate = self
        photosCollection.dataSource = self
        
        
        formatter.dateFormat = "dd.MM.yyyy"
        result = formatter.string(from: date)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        inPath = indexPath
        let cellIdentifier = "CollectionViewCell"
        
        guard let cell = photosCollection.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CollectionViewCell  else {
            fatalError("The dequeued cell is not an instance of CollectionViewCell.")
        }
        
        let btnImage = UIImage(named: "delete_icon")
        cell.deleteAction.setImage(btnImage , for: UIControlState.normal)
        cell.deleteAction.isUserInteractionEnabled = false
        cell.deleteAction.isHidden = true
        
        if canDelete{
            cell.deleteAction.isUserInteractionEnabled = true
            cell.deleteAction.isHidden = false
            cell.deleteAction?.layer.setValue(indexPath.row, forKey: "index")
            cell.deleteAction?.addTarget(self, action: #selector(deleteUser), for: UIControlEvents.touchUpInside)
        }
        
        cell.img.layer.borderWidth = 2.0
        cell.img.layer.borderColor = UIColor.green.cgColor
        cell.img.contentMode = .scaleToFill
        
        let image : UIImage = images[indexPath.row].keys.first!
        let imagePath = images[indexPath.row].values.first
       
        //trims the image path string to get the date picture was taken
        if let range = imagePath?.range(of: "Date ") {
            let picDate = imagePath![range.upperBound...]
            cell.string.text = "\(picDate)"
        }
        
        cell.img.image = image
        
        return cell
    }
    
    
    func deleteUser(sender:UIButton) {
        
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        let x = images[i].values.first
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: x!)
        images.remove(at: i)
        photosCollection.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !canDelete{
            //tapped picture goes to fullscreen
            let img : UIImage = images[indexPath.row].keys.first!
            
            let newImageView = UIImageView(image: img)
            
            newImageView.frame = UIScreen.main.bounds

            newImageView.backgroundColor = .black
            
           // newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
           
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
            newImageView.addGestureRecognizer(pan)
            
            self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @IBAction func editButton(_ sender: Any) {
        
        if canDelete{
            canDelete = false
        }
        else{
            canDelete = true
        }
        //this calls the top collectionView function and different code is called
        //depending on the canDelete boolean being true or false
        photosCollection.reloadData()
        
    }
    
    func handleSwipeGesture(sender: UIPanGestureRecognizer) {
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
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {(_ granted: Bool) -> Void in
            if granted {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.delegate = self
                    imagePicker.sourceType = .camera;
                    imagePicker.allowsEditing = false
                    self.present(imagePicker, animated: true, completion: nil)
                }
            } else {
                let myalert = UIAlertController(title: "You need to go to settings and accept camera permissions", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Done")
                })
         
                self.present(myalert, animated: true)
            }
        })

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //the image is passed to the saveImage function where it is added to the
        //images array and also persisted to memory using fileManager.createFile
        dismiss(animated:true, completion: nil)
        saveImage(image)
        photosCollection.reloadData()
    }
    
    func saveImage(_ image: UIImage){
        
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Image\(image.debugDescription), Date \(result!)")
        print(imagePath)
        
        //The second parameter represents JPEG quality, where 1.0 is highest and 0.0 is lowest.
        
        let data = UIImageJPEGRepresentation(image, 1)
        images.append([image : imagePath])
        
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    
    func getImages(){
        
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        
        for i in directoryContents{
            //  try? fileManager.removeItem(atPath: i.path)
            
            if let image = UIImage(contentsOfFile: i.path) {
                images.append([image : i.path])

            } else {
                fatalError("Can't create image from file \(i)")
            }
        }
    }
}
