//
//  DetailsTableViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 27/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController, UIPopoverControllerDelegate {
    
    let dateformatter = DateFormatter()
    var data: [[String:AnyObject]]?
    let name : String? = nil
    
    var sumMoisture : Int? = 0
    var sumTemp : Double? = 0
    var sumLight : Double? = 0
    
    var avgs = [String: AnyObject]()
    
    var divider: Int? = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {

        avgs["moisture"] = sumMoisture!/divider! as AnyObject
        
        var avgt = sumTemp!/Double(divider!)
        avgt.round()
        avgs["temp"] = Double(round(1000*avgt)/1000) as AnyObject
        
        var avgl = sumLight!/Double(divider!)
        avgl.round()
        avgs["light"] = avgl as AnyObject
        
    }
    
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        //do som stuff from the popover
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.count)!
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "DetailsTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailsTableViewCell;
        
        var item = self.data![indexPath.row]
        
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let day = item["time_value"] as! String? ?? "nil"
        
        let a = day.replacingOccurrences(of: "T", with: " ")
        let b = a.replacingOccurrences(of: ".000Z", with: "")
        
        let date = dateformatter.date(from: b)
        
        dateformatter.dateFormat = "h:mm a"
        let time = dateformatter.string(from: date!)
        
        let m = item["moisture"] as! Int
        var t = item["temp"] as! Double
        var l = item["light"] as! Double
        
        t.round()
        l.round()
        cell?.moisture!.text = "\(m)%"
        cell?.temp!.text = "\(t)°C"
        cell?.light!.text = "\(l)%"
        cell?.time.text = time
        sumMoisture = sumMoisture! + m
        sumTemp = sumTemp! + t
        sumLight = sumLight! + l
        divider = indexPath.last! + 1
        
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "avgValues" {
            let controller = segue.destination as! AvgValuesViewController
            controller.data = avgs
        }
        
        if segue.identifier == "ChartView" {
            let controller = segue.destination as! ChartViewController
            controller.values = data
        }
    }
}

