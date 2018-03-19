//
//  PlantDataViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 06/03/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class PlantDataViewController: UIViewController {
    var data: [String:AnyObject]?
 
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var addButton: UIButton!
    @IBOutlet var img: UIImageView!
    @IBOutlet var desc: UILabel!
 
    @IBOutlet var maintenanceScroll: UIScrollView!
    @IBOutlet var descScroll: UIScrollView!

    @IBOutlet var soil: UILabel!
    @IBOutlet var sun: UILabel!
    @IBOutlet var maintenance: UILabel!
    @IBOutlet var characteristics: UILabel!

    @IBOutlet var textBckgrnd: UIImageView!
    
    @IBOutlet var useBckGrnd: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.alpha = 0.9
        backgroundImage.image = UIImage(named: "leaves.png")
        self.view.insertSubview(backgroundImage, at: 0)

        textBckgrnd.alpha = 0.8
        textBckgrnd.layer.cornerRadius = 8
        
        useBckGrnd.alpha = 0.8
        useBckGrnd.layer.cornerRadius = 8
      
        scrollView.contentSize = CGSize(width: view.frame.width, height: 1000)
        
        self.title = (data!["name"] as! String)
        desc.text = (data?["desc"] as! String)
        soil.text = (data?["soil"] as! String)
        sun.text = (data?["sun"] as! String)
        maintenance.text = (data?["maintenance"] as! String)
        
        let url = URL(string: data?["img"]  as! String)
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            DispatchQueue.main.async {
                self.img.image = UIImage(data: data!)
            }
            }.resume()
        
        desc.sizeToFit()
        maintenance.sizeToFit()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func add(_ sender: Any) {
        let myalert = UIAlertController(title: "\(data!["name"] as! String) has been added to the homepage", message: nil, preferredStyle: UIAlertControllerStyle.alert)

        myalert.addAction(UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
            print("Done")
        })
        let name = data!["name"] as! String
        let image = data!["img"] as! String
        let soil = data?["soil"] as! String
        let sun = data?["sun"] as! String
        
        self.present(myalert, animated: true)
        
        UserDefaults.standard.set(name, forKey: "name") //setObject
        UserDefaults.standard.set(image, forKey: "image")
        UserDefaults.standard.set(soil, forKey: "soil")
        UserDefaults.standard.set(sun, forKey: "sun")
    }

}

