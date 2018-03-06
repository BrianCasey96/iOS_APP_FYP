//
//  DemoJSONTableViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 12/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import UIKit

class DemoJSONTableViewController: UITableViewController, UISearchBarDelegate {
    
    let gd = getData()
    @IBOutlet var searchBar: UISearchBar!
    
    var listData = [[String: AnyObject]]()
    var Dets : [String] = []
    var filtered = [String]()
    let refresh = UIRefreshControl()
    var numberOfRowsAtSection: [Int] = []
    var DateArray = [String]()
    
    var isSearching = false
    
    let dateformatter = DateFormatter()
    var data: [PlantData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshFromServer()
        
        refresh.addTarget(self, action: #selector(self.refreshFromServer), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refresh)
        tableView.reloadData()
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.search
//  
//        gd.refreshDataFromServer()
//        self.data = gd.populatePlantData()
//        print ("Data from proper \(self.data)")
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func refreshFromServer(){
        refresh.beginRefreshing()
        tableView.delegate = self
        tableView.dataSource = self
        
        let url:String = "http://35.198.67.227:8080/allData"
        let urlRequest = URL(string : url)
        
        URLSession.shared.dataTask(with: urlRequest!, completionHandler: {
            (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 500..<600:
                    print("Server error \(httpResponse.statusCode)")
                     self.title = "Server request error \(httpResponse.statusCode)"
                case 400..<500:
                    print("Client request error \(httpResponse.statusCode)")
                    self.title = "Client request error \(httpResponse.statusCode)"
                default:
                    print("")
                }
            }
            
            if(error != nil){
                print(error.debugDescription)
            }else{
                do{
                    self.listData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [[String: AnyObject]]
                    
                    DispatchQueue.main.async() { () -> Void in
                        self.tableView.reloadData()
                        self.refresh.endRefreshing()
                     //   self.data = self.gd.populatePlantData()
                      //  print(self.data)
                        
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
    
    func reformatDates()-> [String]{
        let dates = getDateFromEachSection()
        var newDates = [String]()
        for day in dates{
            
            dateformatter.dateFormat = "yyyy-MM-dd"
            
            let date = dateformatter.date(from: day)
            dateformatter.dateFormat = "EEE dd, MMM yy"
            let time = dateformatter.string(from: date!)
            
            newDates.append(time)
            
        }
        return newDates
    }
    
    func sortDatabyDate() -> [[String: AnyObject]]{
        var myArray = [[String: AnyObject]]()
        var x = 1
        var num_elements = 0
        var section = 0
        
        while x < listData.count - 1{
            let value = listData[x]["time_value"]
       
            let valueSplit = value?.lastPathComponent.split(separator:"T").map(String.init)
            let nextValue = listData[x+1]["time_value"]
            let nextValueSplit = nextValue?.lastPathComponent?.split(separator:"T").map(String.init)
            
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
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            
            isSearching = false
            self.view.endEditing(true)
            tableView.reloadData()
        }
            
        else{
            isSearching = true
            let dates = reformatDates()
            filtered = dates.filter({
                $0.range(of: searchText, options: .caseInsensitive) != nil
            })
            tableView.reloadData()
        }
    }
    
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
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // let x = sortDatabyDate()
        // return x.count
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell;
        
        var time: String? = nil
        
        var dates = reformatDates()
        time = dates[indexPath.row]
        
        if isSearching{
            cell?.date!.text = filtered[indexPath.row]
        }
        else{
            cell?.date!.text = time
        }
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching{
            print("Fitered count is \([filtered.count])")
            return filtered.count
        }
        
        let dates = getDateFromEachSection()
        return dates.count
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let index = tableView.indexPathForSelectedRow?.row
        var loops = -1
        let x = sortDatabyDate()
        
        var startRange = 0
        var endRange = 0
        var num = 0
        
        for i in x.enumerated().reversed(){
            
            loops = loops + 1
            num = i.element.values.first as! Int
            
            if index == 0{
                startRange = 0
            }
            
            if loops == index{
                startRange = startRange + 1
                endRange = startRange + num
                break
            }
            startRange = startRange + num
        }
        
        let date = x.reversed()[index!].keys.first
        
        
        let data = listData.reversed()[startRange..<endRange]
        
        let rangeOfValues: [[String:AnyObject]] = Array(data)
        
        if segue.identifier == "next" {
            //Creating an object of the second View controller
            let controller = segue.destination as! DetailsTableViewController
            controller.data = rangeOfValues
            controller.title = date
        }
        
    }
    
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


