
//  FirstPageViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 12/02/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit
import CocoaMQTT

class FirstPageViewController: UIViewController {

    
    @IBOutlet var sunType: UILabel!
    @IBOutlet var soilType: UILabel!
    @IBOutlet var descBottom: UIImageView!
    @IBOutlet var textBckgrnd: UIImageView!
    @IBOutlet var plantImage: UIImageView!
    @IBOutlet var temp: UILabel!
    @IBOutlet var light: UILabel!
    @IBOutlet var time_watered: UILabel!
    
    @IBOutlet var waterimg: UIImageView!
 
    @IBOutlet var time: UILabel!
    
    var type : String? = nil
    var picture : String? = nil
    var soil : String? = nil
    var sun : String? = nil
    
    let refresh = UIRefreshControl()
    var mqtt : CocoaMQTT?
    
    var topValue = [[String: AnyObject]]()
    let dateformatter = DateFormatter()
    let calendar = NSCalendar.current
   // var top : [PlantData]?
    
    let shapeLayer = CAShapeLayer()
    let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
    
    let circleLabel: UILabel = {
        let label = UILabel()
        label.text = "Nil"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        return label
    }()
    
    var m : Int = 0
    var t : Double = 0
    var l : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.alpha = 0.9
        backgroundImage.image = UIImage(named: "leaves.png")
        self.view.insertSubview(backgroundImage, at: 0)

        refreshFromServer()
        
        waterimg.image = #imageLiteral(resourceName: "waterCan")
        waterimg.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        waterimg.addGestureRecognizer(tapRecognizer)
        view.addSubview(waterimg)
        
        plantImage.isUserInteractionEnabled = true
        let plantImageTap = UITapGestureRecognizer(target: self, action: #selector(plantImageTapped))
        plantImage.addGestureRecognizer(plantImageTap)
        
        mqttSetting()
        
        textBckgrnd.alpha = 0.8
        textBckgrnd.layer.cornerRadius = 8
        
        descBottom.alpha = 0.8
        descBottom.layer.cornerRadius = 8
        
        //make plant image circular
        let radius = plantImage.frame.height / 2
        plantImage.layer.cornerRadius = radius
        plantImage.layer.masksToBounds = true
        
        let tabBarController: UITabBarController?
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(circleLabel)
        
        circleLabel.frame = CGRect(x:0, y:0, width: 75, height: 75 )
        circleLabel.center = view.center
        addCircleBar()

        type = UserDefaults.standard.string(forKey: "name")
        picture = UserDefaults.standard.string(forKey: "image")
        soil = UserDefaults.standard.string(forKey: "soil")
        sun = UserDefaults.standard.string(forKey: "sun")
        
        if (type ?? "").isEmpty{
            return
        }
        else{
            self.title = type
            sunType.text = "Needs \(sun!)."
            soilType.text = "Plant \(soil!)."
            let url = URL(string: picture!)
            let request = URLRequest(url: url!)
            URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                DispatchQueue.main.async {
                    self.plantImage.image = UIImage(data: data!)
                }
                }.resume()
        }
    }
    
    func mqttSetting() {
        let clientID = "iOS Device"
        let defaultHost = "35.198.67.227"
        mqtt = CocoaMQTT(clientID: clientID, host: defaultHost, port: 1883)
        mqtt!.delegate = self
        mqtt?.connect()
    }
    
    func plantImageTapped(recognizer: UITapGestureRecognizer){
        let imageView = recognizer.view as? UIImageView
        if imageView != nil {
         tabBarController?.selectedIndex = 3
        }
    }
    
    func imageTapped(recognizer: UITapGestureRecognizer) {
        let imageView = recognizer.view as? UIImageView
        if imageView != nil {
            print("water plant")
            mqtt!.publish("rpi/gpio", withString: "on")
           // let date = Date()
           // self.dateformatter.dateFormat = "h:mm a"
           // let result =  self.dateformatter.string(from: date)
            //time_watered.text = "Plant last watered at \(result)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10), execute: {
                self.refreshFromServer()
            })
            
        }
    }
    
    func addCircleBar(){
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 65, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        
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
        
        basicAnimation.duration = 2
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "key")
    }
    
    func refreshFromServer(){
        refresh.beginRefreshing()
        let url:String = "http://35.198.67.227:8080/top"
        let urlRequest = URL(string : url)
        
        URLSession.shared.dataTask(with: urlRequest!, completionHandler: {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 500..<600:
                    print("Server error \(httpResponse.statusCode)")
                    self.time.text = "Server error \(httpResponse.statusCode)"
                case 400..<500:
                    print("Client request error \(httpResponse.statusCode)")
                    self.time.text = "Server error \(httpResponse.statusCode)"
                default:
                    print("")
                }
            }
            
            if(error != nil){
                self.m = 0
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
                        //   self.moisture.text = "\(self.m)%"
                        self.temp.text = "\(self.t)°C"
                        self.light.text = "\(self.l)%"
                        
                        self.refresh.endRefreshing()
                        
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
        
    }
    
    @IBAction func waterPlant(_ sender: Any) {
        print("water plant")
        mqtt!.publish("rpi/gpio", withString: "on")
        sleep(5)
        refreshFromServer()
        
    }
    
    @IBAction func update(_ sender: Any) {
        refreshFromServer()
    }
    
}

extension UIViewController: CocoaMQTTDelegate {
    
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int)
    {
        print("connected to host: \(host) on port: \(port)")
    }
    
    public func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck)
    {
        print("connection ack")
    }
    public func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16)
    {
        print("published")
    }
    public func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16)
    {
        print("publish ack")
        
        let myalert = UIAlertController(title: "Plant Watered", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        myalert.addAction(UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
            print("Done")
        })
        
        self.present(myalert, animated: true)
    }
    public func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 )
    {
        print("recived message: \(message.string ?? message.topic)")
    }
    public func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String)
    {
        print("subscribed")
    }
    public func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String)
    {
        print("unsuscribed")
    }
    public func mqttDidPing(_ mqtt: CocoaMQTT)
    {
        print("ping")
    }
    public func mqttDidReceivePong(_ mqtt: CocoaMQTT)
    {
        print("pong")
    }
    public func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?)
    {
        print("disconnected: \(err.debugDescription)")
        Timer.after(5.seconds) {
            _ = mqtt.connect()
        }
    }
}

