
//  FirstPageViewController.swift
//  PlantApp
//
//  Created by Casey, Brian on 12/02/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit
import CocoaMQTT
import UserNotifications
import SystemConfiguration

class FirstPageViewController: UIViewController {

    @IBOutlet var descBottom: UIImageView!
    @IBOutlet var textBckgrnd: UIImageView!
    @IBOutlet var plantImage: UIImageView!
    @IBOutlet var temp: UILabel!
    @IBOutlet var light: UILabel!
    
    @IBOutlet var waterimg: UIImageView!
 
    
    @IBOutlet var time: UILabel!
    
    @IBOutlet var adviseLight: UILabel!
    @IBOutlet var adviseMoisture: UILabel!

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
    @IBOutlet var moistureAlert: UIButton!
    @IBOutlet var lightAlert: UIButton!
    let circleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
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
        
        mqttSettings()
        
        textBckgrnd.alpha = 0.8
        textBckgrnd.layer.cornerRadius = 8
        descBottom.alpha = 0.8
        descBottom.layer.cornerRadius = 8
        
        //make plant image circular
        let radius = plantImage.frame.height / 2
        plantImage.layer.cornerRadius = radius
        plantImage.layer.masksToBounds = true
        
        //these images will be shown if the user needs to take action
        lightAlert.isHidden = true
        moistureAlert.isHidden = true
        animateInfoButtons()

         UNUserNotificationCenter.current().delegate = self
        
        //Refreshes the app when it is in foreground and animates again when app is reopened
        NotificationCenter.default.addObserver(self, selector:#selector(refreshFromServer), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        notification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshFromServer()
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
        sun = UserDefaults.standard.string(forKey: "sun")
        
        
        if (type ?? "").isEmpty{
            adviseLight.text = "Choose your plant from the search tab"
        }
        else{
            self.navigationItem.title = type

            let url = URL(string: picture!)
            let request = URLRequest(url: url!)
            URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                DispatchQueue.main.async {
                    self.plantImage.image = UIImage(data: data!)
                    print(url!)
                }
                }.resume()
        }
    }
    
    func refreshFromServer(){
        refresh.beginRefreshing()
        let url:String = "http://35.198.67.227:8080/top"
        let urlRequest = URL(string : url)
        
        URLSession.shared.dataTask(with: urlRequest!, completionHandler: {
            (data, response, error) in
            
            if(error != nil){
                self.m = 0
                print(error.debugDescription)
                let errorAlert = UIAlertController(title: "Error getting the data. Please check your internet connection.", message: nil, preferredStyle: UIAlertControllerStyle.alert)
                
                errorAlert.addAction(UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction!) in
                })
                
                self.present(errorAlert, animated: true)
                
            }else{
                do{
                    self.topValue = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: AnyObject]]
                    
                    let x = self.topValue[0]
                    let date = x["time_value"] as! String
                    let time = self.fixDateFormat(value: date)
                    
                    DispatchQueue.main.async() { () -> Void in
                        self.m = x["moisture"] as! Int
                        self.t = x["temp"] as! Double
                        self.l = x["light"] as! Double
                        
                        self.circleLabel.text = "\(self.m)%"
                        self.basicAnimation.toValue = (Double(self.m)/Double(100))
                        self.animateCircle()
                        
                        self.t.round()
                        self.l.round()
                        
                        self.time.text = "\(time)"
                        self.temp.text = "\(self.t)°C"
                        self.light.text = "\(self.l)%"
                        
                        self.adviseUser(light: self.l, mositure: self.m)
                        self.refresh.endRefreshing()
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
    }
    
    
    func adviseUser(light: Double, mositure: Int){
        
        if (sun?.elementsEqual("full sun"))!{
            if (light > 70){
                adviseLight.text = "Light levels are at optimal for full sun"
                lightAlert.isHidden = true
            }
            else{
                adviseLight.text = "Allow the plant more sunlight"
                lightAlert.isHidden = false
            }
        }
        else if (sun?.elementsEqual("part shade"))!{
            if (light < 70 || light > 40){
                adviseLight.text = "Light levels are at optimal for part shade"
                lightAlert.isHidden = true
            }
                
            else{
                adviseLight.text = "Use less light."
                lightAlert.isHidden = false
            }
        }
        
        if mositure < 40{
            adviseMoisture.text? = "Increase moisture level to 60%"
            moistureAlert.isHidden = false
           
        }
        else if mositure > 60{
            adviseMoisture.text = "Mositure level is a little too high"
            moistureAlert.isHidden = false
        }
        
        else if (mositure > 40 && mositure < 60){
            adviseMoisture.text = "Mositure level is good"
            moistureAlert.isHidden = true
        }
        else{
            adviseMoisture.text = "Alert"
            moistureAlert.isHidden = false
        }
    }
    
    func mqttSettings() {
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
    
    func animateInfoButtons(){
        //  let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 0.7
        // pulseAnimation.duration = 1
        pulseAnimation.fromValue = 1
        pulseAnimation.toValue = 0.8
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .greatestFiniteMagnitude
        moistureAlert.layer.add(pulseAnimation, forKey: "animateOpacity")
        lightAlert.layer.add(pulseAnimation, forKey: "animateOpacity")
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
    
    @IBAction func update(_ sender: Any) {
        refreshFromServer()
    }
    
    func fixDateFormat(value: String )-> String{
        self.dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let a = value.replacingOccurrences(of: "T", with: " ")
        let b = a.replacingOccurrences(of: ".000Z", with: "")
        
        let date = self.dateformatter.date(from: b)
        
        self.dateformatter.dateFormat = "h:mm a"
        let time = self.dateformatter.string(from: date!)
        return time
        
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            if let error = error {
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
    private func scheduleLocalNotification() {
        // Create Notification Content
        let content = UNMutableNotificationContent()
        content.title = "Don't forget to water your plant"
        content.body = "Mositure Level is getting low"
        content.sound = UNNotificationSound.default()
        
        // Add Trigger
       let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        
        // Create Notification Request
        let request = UNNotificationRequest(identifier: "LocalNotification", content: content, trigger: trigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    func notification(){
        
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    
                    self.scheduleLocalNotification()
                })
            case .authorized:
                self.scheduleLocalNotification()
            case .denied:
                print("Application Not Allowed to Display Notifications")
            }
        }
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

extension FirstPageViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
}

