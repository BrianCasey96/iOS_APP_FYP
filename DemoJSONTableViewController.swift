//
//  DemoJSONTableViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 12/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import UIKit

//struct plant_details{
//    let date: String
//    let mositure: String
//    let light: String
//    let temperature: String
//}

class DemoJSONTableViewController: UITableViewController, UISearchBarDelegate {
    
    var listData = [[String: AnyObject]]()
    var Dets : [String] = []
    var filtered : [String] = []
    let refresh = UIRefreshControl()
    var numberOfRowsAtSection: [Int] = []
    var sectionData = [[[String: AnyObject]]]()
//    var contacts: [Person] = []
    
    // var sendSelectedData = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFromServer()
         refresh.addTarget(self, action: #selector(self.refreshFromServer), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refresh)
        tableView.reloadData()
        
    }
    
    func refreshFromServer(){
        refresh.beginRefreshing()
        tableView.delegate = self
        tableView.dataSource = self
        let url:String = "https://fyppi.000webhostapp.com/service.php"
        let urlRequest = URL(string : url)
        
        URLSession.shared.dataTask(with: urlRequest!, completionHandler: {
            (data, response, error) in
            if(error != nil){
                print(error.debugDescription)
            }else{
                do{
                    self.listData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: AnyObject]]
                    
                    DispatchQueue.main.async() { () -> Void in
                        
                        self.tableView.reloadData()
                        self.refresh.endRefreshing()
                        
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
        
        numberOfRowsAtSection = getNumofRows()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sortDatabyDate() -> [[String: AnyObject]]{
        var myArray = [[String: AnyObject]]()
        var x = 1
        var num_elements = 0
        var section = 0
        
        while x < listData.count - 1{
            let value = listData[x]["Date"]
            let valueSplit = value?.lastPathComponent?.characters.split(separator:" ").map(String.init)
           
            let nextValue = listData[x+1]["Date"]
            let nextValueSplit = nextValue?.lastPathComponent?.characters.split(separator:" ").map(String.init)
            
            
            num_elements = num_elements + 1
           // sectionData.append([[section][listData[num_elements]]])
            if valueSplit?.first != nextValueSplit?.first{
                myArray.append([(valueSplit?.first)!: num_elements as AnyObject])
                num_elements = 0
                section = section + 1
            }
            x = x + 1
            
            if x == listData.count - 1{
                myArray.append([(valueSplit?.first)!: num_elements as AnyObject])
            }
            
            
        }
        
        return myArray
////    if(l["Date"]?.contains("06"))!{
////    print(l["Date"])

    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let x = sortDatabyDate()
        return x.count
        //return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        var absoluteRow: Int = indexPath.row
        
        for section in 0..<indexPath.section {
            absoluteRow += tableView.numberOfRows(inSection: section)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell;
        
        //let item = self.listData[indexPath.row]
        //uses absolute Row instead of IndexPath, because IndexPath.row resets itself to 0 at each new section
        let item = self.listData.reversed()[absoluteRow+1]
        print("Index Path : - - - - - \(indexPath.row)")
        
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let day = item["Date"] as! String?
        let date = dateformatter.date(from: day!)
        
        // changes to a readable time format
       // dateformatter.dateFormat = "EEE, MMM d, yyyy - h:mm a"
        dateformatter.dateFormat = "h:mm a EEE dd, MMM"
        let time = dateformatter.string(from: date!)
        
        cell?.moisture!.text = "\(item["Moisture"] as! String? ?? "nil")%"
        cell?.temp!.text = "\(item["Temp"] as! String? ?? "nil")°C"
        cell?.light!.text = "\(item["Light"] as! String? ?? "nil")%"
        cell?.date!.text = time
        
        return cell!
    }
    
    func getNameofRows() -> [String]{
        let x = sortDatabyDate()
        var numberOfRowsAtSection: [String] = []
        
        for i in x.enumerated(){
            numberOfRowsAtSection.append(i.element.keys.first!)
            
        }
        numberOfRowsAtSection.reverse()
        return numberOfRowsAtSection
    }
    
    
    func getNumofRows() -> [Int]{
        let x = sortDatabyDate()
        var numberOfRowsAtSection: [Int] = []
        
        for i in x.enumerated(){
            numberOfRowsAtSection.append(i.element.values.first as! Int)
            
        }
        numberOfRowsAtSection.reverse()
        return numberOfRowsAtSection
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.numberOfRowsAtSection = getNumofRows()
        print("Array Called ---- \(numberOfRowsAtSection)")
        
        //let a = x[2].keys.first
        //print(a)
       
        
        var rows: Int = 0
        print("Section number ---- \(section)")
        print("Number of rows at section ---- \(self.numberOfRowsAtSection[section])")

        if section < self.numberOfRowsAtSection.count {
            print("true")
            rows = self.numberOfRowsAtSection[section]
        }
        
        print("Rows \(rows)")
        return rows
        //return self.listData.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        //Here i am checking the Segue and Saving the data to an array on the next view Controller also sending it to the next view COntroller
        let index = tableView.indexPathForSelectedRow?.row
        let data =  listData[index!]
        
        if segue.identifier == "next" {
            //Creating an object of the second View controller
            let controller = segue.destination as! DetailsController
            controller.data = data
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var nameOfRowsAtSection = getNameofRows()
        print("Names from array  Called ---- \(nameOfRowsAtSection)")
        
        var rowName: String = ""

        if section < nameOfRowsAtSection.count {
            rowName = nameOfRowsAtSection[section]
        }
        print("RowName \(rowName)")
        return rowName
        
        //return "Plant"
    }

    //        override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
//        let vw = UIView()
//        vw.backgroundColor = UIColor.gray
//        return vw
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
     
     */
}
