//
//  DetailsTableViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 27/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    
    let dateformatter = DateFormatter()
    var data: [[String:AnyObject]]?
    let name : String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        //print()
        
        let m = item["moisture"] as! Int
        let t = item["temp"] as! Double
        let l = item["light"] as! Double
        
        cell?.moisture!.text = "\(m)%"
        cell?.temp!.text = "\(t)°C"
        cell?.light!.text = "\(l)%"
        cell?.time.text = time
        
        return cell!
    }
    
    //     override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //
    //       // return self.title
    //
    //    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

