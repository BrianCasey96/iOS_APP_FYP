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
    
    @IBOutlet var img: UIImageView!
    @IBOutlet var desc: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var soil: UILabel!
    @IBOutlet var sun: UILabel!
    @IBOutlet var maintenance: UILabel!
    @IBOutlet var characteristics: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height+100)

        desc.text = data?["desc"] as! String
        soil.text = data?["soil"] as! String
        sun.text = data?["sun"] as! String
        maintenance.text = data?["maintenance"] as! String

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
    
    
    
}

