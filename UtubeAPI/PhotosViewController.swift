//
//  PhotosView.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 25/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class PhotosViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegate{
    
  //  var images : [UIImage] = []
    var inPath : IndexPath? = nil
    var canDelete = false
    var imgs = [[UIImage: String]]()
    
    @IBOutlet var photosCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImage()
        photosCollection.delegate = self
        photosCollection.dataSource = self

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgs.count
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
        
        cell.string.text = "Image \(indexPath.row+1)"
       // let image : UIImage = images[indexPath.row]
        let image : UIImage = imgs[indexPath.row].keys.first!
        
        cell.img.image = image
        
        return cell
    }
    
   
    func deleteUser(sender:UIButton) {
        
        let i : Int = (sender.layer.value(forKey: "index")) as! Int
        let x = imgs[i].values.first
       // images.remove(at: i)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: x!)
        imgs.remove(at: i)
        photosCollection.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if !canDelete{
            let img : UIImage = imgs[indexPath.row].keys.first!
            
            let newImageView = UIImageView(image: img)
            
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            
            newImageView.contentMode = .scaleAspectFit
           // newImageView.frame = CGRect(0, 0, 375, 667)
            newImageView.isUserInteractionEnabled = true
            newImageView.clipsToBounds = true
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            newImageView.addGestureRecognizer(pan)
            print(newImageView.description)
            //
            
            //        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            //        newImageView.addGestureRecognizer(tap)
            //
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
        photosCollection.reloadData()
    
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
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
        
        saveImage(image)

        dismiss(animated:true, completion: nil)
        photosCollection.reloadData()
    }
    
    func saveImage(_ image: UIImage){
        
        let fileManager = FileManager.default
        
        let imagePath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("Image\(image.description)")
        
        let data = UIImagePNGRepresentation(image)
        imgs.append([image : imagePath])
        
        print("Added Image \(imagePath)")
        fileManager.createFile(atPath: imagePath as String, contents: data, attributes: nil)
    }
    
    func getImage(){
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
 
        for i in directoryContents{
          //  try? fileManager.removeItem(atPath: i.path)
            
            if let image = UIImage(contentsOfFile: i.path) {
                imgs.append([image : i.path])
            } else {
                fatalError("Can't create image from file \(i)")
            }
        }

        
    }
    
}




