//
//  AvgValuesViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 18/03/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class AvgValuesViewController: UIViewController {

    @IBOutlet var moisture: UILabel!
    
    @IBOutlet var temp: UILabel!
    @IBOutlet var light: UILabel!
    @IBOutlet var popupView: UIView!
    
   var data: [String:AnyObject]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let m = data!["moisture"], let t = data!["temp"], let l = data!["light"]{
            moisture.text = "Moisture : \(m)%"
            temp.text = "Temperature : \(t)°C"
            light.text = ("Light : \(l)%")
        } 
        
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissPopover(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
