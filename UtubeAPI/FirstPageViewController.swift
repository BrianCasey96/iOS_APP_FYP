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
    let dateformatter = DateFormatter()
    let calendar = NSCalendar.current
    var top : [PlantData]?
    
 
    
    let shapeLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    let circleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nil"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    var m : Int = 0
    var t : Double = 0
    var l : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFromServer()
        
        // self.addTarget(self, action: #selector(refreshFromServer), for: .valueChanged)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        view.addSubview(circleLabel)
//
//        circleLabel.frame = CGRect(x:0, y:0, width: 50, height: 50 )
//        circleLabel.center = view.center
//
//        addCircleBar()
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(circleLabel)
        
        circleLabel.frame = CGRect(x:0, y:0, width: 50, height: 50 )
        circleLabel.center = view.center
        
        addCircleBar()
    }
    
    
    func addCircleBar(){
        
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.green.cgColor
        trackLayer.lineWidth = 10
        
        trackLayer.lineCap = kCALineCapRound
        trackLayer.strokeEnd = 1
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.position = view.center
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.blue.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.position = view.center
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        shapeLayer.fillColor = UIColor.clear.cgColor
        
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(shapeLayer)
        
    }
    
    func animateCircle(){
        
       // basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false

        shapeLayer.add(basicAnimation, forKey: "key")
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
                    
                    
                        print(self.topValue)
                        let x = self.topValue[0]
                        
                        self.dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let value = x["time_value"]
                        
                        let a = value?.replacingOccurrences(of: "T", with: " ")
                        let b = a?.replacingOccurrences(of: ".000Z", with: "")
                        
                        let date = self.dateformatter.date(from: b!)
                        
                        self.dateformatter.dateFormat = "h:mm a"
                        let time = self.dateformatter.string(from: date!)
                    
                    DispatchQueue.main.async() { () -> Void in
                        self.m = x["moisture"] as! Int
                        self.t = x["temp"] as! Double
                        self.l = x["light"] as! Double
                        
                        self.circleLabel.text = "\(self.m)%"
                     
                        let newVal: Double = (Double(self.m)/Double(100))
                        self.basicAnimation.toValue = newVal
                        self.animateCircle()
                        
                        
                        self.time.text = "\(time)"
                        self.moisture.text = "\(self.m)%"
                        self.temp.text = "\(self.t)°C"
                        self.light.text = "\(self.l)%"
                        
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

