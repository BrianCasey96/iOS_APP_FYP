//
//  FirstPageViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 12/02/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class FirstPageViewController: UIViewController {
    @IBOutlet var moisture: UILabel!
    @IBOutlet var temp: UILabel!
    @IBOutlet var light: UILabel!
    
    @IBOutlet var time: UILabel!
    var topValue = [[String: AnyObject]]()
    
    var top : [PlantData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFromServer()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshFromServer(){
        let url:String = "http://35.198.67.227:8080/top"
        let urlRequest = URL(string : url)
    
        URLSession.shared.dataTask(with: urlRequest!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error.debugDescription)
            }else{
                do{
                    self.topValue = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: AnyObject]]
                    
                    DispatchQueue.main.async() { () -> Void in
                        print(self.topValue)
                        let x = self.topValue[0]

                        let m = x["moisture"] as! Int
                        let t = x["temp"] as! Double
                        let l = x["light"] as! Double
                        
                        self.moisture.text = "\(m)%"
                        self.temp.text = "\(t)°C"
                        self.light.text = "\(l)%"

                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
        
    }
 
    @IBAction func waterPlant(_ sender: Any) {
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
