//
//  DetailsController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 13/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import UIKit

class DetailsController: UIViewController {

    @IBOutlet weak var dets: UILabel!
    
    @IBOutlet weak var pict: UIImageView!
    
    var data: [String:AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.lightGray
        
        self.dets.text = data?["title"] as? String
       // self.pict.image = data?["thumbnailUrl"] as? UIImage
        
        let url = URL(string: data?["url"]  as! String)
        let request = URLRequest(url: url!)
        URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            DispatchQueue.main.async {
                self.pict.image = UIImage(data: data!)
            }
            }.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
