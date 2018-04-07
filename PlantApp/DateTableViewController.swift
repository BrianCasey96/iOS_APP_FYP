//
//  DateTableViewController.swift
//  PlantApp
//
//  Created by Casey, Brian on 12/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import UIKit

class DateTableViewController: UITableViewController, UISearchBarDelegate {
    
//  let gd = getData()
    @IBOutlet var searchBar: UISearchBar!
    
    var listData = [[String: AnyObject]]()

    var filtered = [String]()
    let refresh = UIRefreshControl()
 //   var numberOfRowsAtSection: [Int] = []
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
        searchBar.returnKeyType = UIReturnKeyType.done

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
    
    // if there is one value for today it duplicates the last date there was data in the table view
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
            
            //get last date from listData
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
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.endEditing(true)
    }
    
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
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
//    func getNumofRows() -> [Int]{
//        let x = sortDatabyDate()
//
//        for i in x.enumerated(){
//            numberOfRowsAtSection.append(i.element.values.first as! Int)
//
//        }
//        numberOfRowsAtSection.reverse()
//        return numberOfRowsAtSection
//    }
    
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
        
        //to be able to display 'Today' beside current date
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateformatter.string(from: Date())
        let today = dateformatter.date(from: date)
        dateformatter.dateFormat = "EEE dd, MMM yy"
        let now = dateformatter.string(from: today!)
       
        
        if isSearching{
            cell?.date!.text = filtered[indexPath.row]
        }
        else{
           
            let isEqual = (now == time) // is a boolean
            if isEqual {
                cell?.date!.text = "\(time!) - Today"
            }
            else{
                cell?.date!.text = time
            }
        }
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching{
            return filtered.count
        }
        
        let dates = getDateFromEachSection()
        return dates.count
    }
    
    func getCellValues() -> (String, [[String:AnyObject]]){
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
        
        return (date!, rangeOfValues)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        let (date, rangeOfValues) = getCellValues()
        
        if segue.identifier == "next" {
            //Creating an object of the second View controller
            let controller = segue.destination as! DetailsTableViewController
            controller.title = date
            controller.data = rangeOfValues
        }
    }
}


