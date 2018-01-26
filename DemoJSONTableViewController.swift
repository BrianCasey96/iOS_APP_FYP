//
//  DemoJSONTableViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 12/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import UIKit

class DemoJSONTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    
    var listData = [[String: AnyObject]]()
    var Dets : [String] = []
    var filtered = [[String: AnyObject]]()
    let refresh = UIRefreshControl()
    var numberOfRowsAtSection: [Int] = []
    var DateArray = [String]()
    
    var isSearching = false
    
    let dateformatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFromServer()
        refresh.addTarget(self, action: #selector(self.refreshFromServer), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refresh)
        tableView.reloadData()
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.search
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DemoJSONTableViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
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
            let valueSplit = value?.lastPathComponent?.split(separator:" ").map(String.init)
           
            let nextValue = listData[x+1]["Date"]
            let nextValueSplit = nextValue?.lastPathComponent?.split(separator:" ").map(String.init)
            
            
            num_elements = num_elements + 1
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
        
        var item = self.listData.reversed()[absoluteRow+1]
        
//        if isSearching{
//
//            item = self.filtered.reversed()[absoluteRow+1]
//        }
//        else{
        
        item = self.listData.reversed()[absoluteRow+1]
        print("Index Path : - - - - - \(indexPath.row)")
        //}
        
      
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let day = item["Date"] as! String?
        let date = dateformatter.date(from: day!)
        
        dateformatter.dateFormat = "h:mm a"
        let time = dateformatter.string(from: date!)
        
        cell?.moisture!.text = "\(item["Moisture"] as! String? ?? "nil")%"
        cell?.temp!.text = "\(item["Temp"] as! String? ?? "nil")°C"
        cell?.light!.text = "\(item["Light"] as! String? ?? "nil")%"
        cell?.date!.text = time
        
        return cell!
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text == nil || searchBar.text == "" {

            isSearching = false
            self.view.endEditing(true)
            
            tableView.reloadData()
        }
        
    }
//        else{
//            var a = 0
//            var b = 0
//
//            while a < listData.count-1 {
//                let value = self.listData[a]["Date"]
//                DateArray.append(value as! String)
//                a = a + 1
//            }
//
//         //   let xx = listData[0]["Date"] as! String
//            isSearching = true
//
//
//
//
//           // print("Date Array is \(DateArray)")
//           // var arr = [String]()
//           // arr = DateArray.filter{$0 == searchText}
//           // print("SearchText is \(searchText)")
//          //  print("DateArray text \(DateArray)")
//          //  print("in Arr is \(arr)")
//          // DateArray.reversed()
//            while b < DateArray.count - 1{
//              //  for i in DateArray{
//                 //   print("I is \(i)")
//
//                    if DateArray[b].range(of: searchText) != nil {
//                        filtered.append(listData[b])
//                        print("In the Filtered Array is\(listData[b])")
//                    }
////                    if arr[b] == i{
////                        filtered.append(listData[b])
////                        print("In the Filtered Array is\(listData[b])")
////                    }
//                    b = b + 1
//               // }
//            }
//         //   filtered = listData
//            tableView.reloadData()
//        }
//    }
    
    func getDateFromEachSection() -> [String]{
        let x = sortDatabyDate()
        var nameOfRowsForEachSection: [String] = []
        
        for i in x.enumerated(){
            nameOfRowsForEachSection.append(i.element.keys.first!)
            
        }
        nameOfRowsForEachSection.reverse()
        return nameOfRowsForEachSection
    }
    
    // returns an array with the number of rows in each section
    // extracts the value from the dictionary numberOfRowsAtSection
    func getNumofRows() -> [Int]{
        let x = sortDatabyDate()
        
        for i in x.enumerated(){
            numberOfRowsAtSection.append(i.element.values.first as! Int)
            
        }
        numberOfRowsAtSection.reverse()
        
        return numberOfRowsAtSection
    }
    
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.numberOfRowsAtSection = getNumofRows()
        
//        if isSearching{
//
//            print("Fitered count is \([filtered.count])")
//            return filtered.count
//        }
        
        var rows: Int = 0
        print("Section number ---- \(section)")
        print("Number of rows at section ---- \(self.numberOfRowsAtSection[section])")

        if section < self.numberOfRowsAtSection.count {
            rows = self.numberOfRowsAtSection[section]
        }
        
        print("Rows \(rows)")
    
        return rows
        //return self.listData.count
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//
//        //Here i am checking the Segue and Saving the data to an array on the next view Controller also sending it to the next view COntroller
//        let index = tableView.indexPathForSelectedRow?.row
//        let data =  listData[index!]
//
//        if segue.identifier == "next" {
//            //Creating an object of the second View controller
//            let controller = segue.destination as! DetailsController
//            controller.data = data
//        }
//
//    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        var nameOfRowsAtSection = getDateFromEachSection()
      //  print("Names from array  Called ---- \(nameOfRowsAtSection)")

        dateformatter.dateFormat = "yyyy-MM-dd"

        var rowName: String = ""

        if section < nameOfRowsAtSection.count {
            rowName = nameOfRowsAtSection[section]
        }

        let day = rowName
        let date = dateformatter.date(from: day)
        dateformatter.dateFormat = "EEE dd, MMM"
        let time = dateformatter.string(from: date!)
        //print("RowName \(rowName)")
        
//        if isSearching{
//            return " "
//        }

        return time

        //return "Plant"
    }

//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 18))
//        /* Create custom view to display section header... */
//        let label = UILabel(frame: CGRect(x: 10, y: 5, width: tableView.frame.size.width, height: 18))
//        label.font = UIFont.boldSystemFont(ofSize: 12)
//
//        var nameOfRowsAtSection = getDateFromEachSection()
//        var rowName: String = ""
//
//        dateformatter.dateFormat = "yyyy-MM-dd"
//
//        if section < nameOfRowsAtSection.count {
//            rowName = nameOfRowsAtSection[section]
//        }
//
//        let day = rowName
//        let date = dateformatter.date(from: day)
//        dateformatter.dateFormat = "EEE dd, MMM"
//        let time = dateformatter.string(from: date!)
//
//        label.text = time
//        view.addSubview(label)
//        view.backgroundColor = UIColor(red: 166 / 255.0, green: 177 / 255.0, blue: 186 / 255.0, alpha: 1.0)
//
//        return view
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
