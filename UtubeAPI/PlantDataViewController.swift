//
//  PlantDataViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 06/03/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

protocol PlantDataViewDelegate: class {
    func sentData(nom : String)
}

class PlantDataViewController: UIViewController {
    var data: [String:AnyObject]?
    
    weak var delegate: PlantDataViewDelegate?
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var desc: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var soil: UILabel!
    @IBOutlet var sun: UILabel!
    @IBOutlet var maintenance: UILabel!
    @IBOutlet var characteristics: UILabel!
    let fpvc = FirstPageViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = fpvc
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)
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
        print("Name chose in PlantData Controller is \(name)")
       
        let x: String = "Hello Honey"
       
        if let delegate = delegate {
            delegate.sentData( nom: x)
        }
        
        self.present(myalert, animated: true)
    }

}

