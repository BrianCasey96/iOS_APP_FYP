//
//  PlantTableViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 28/02/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit

class PlantTableViewController: UITableViewController, UISearchBarDelegate {
    
    var listData = [[String: AnyObject]]()
    var data = [String: AnyObject]()
    var names = [String]()
    
    var filtered = [String]()
    
    var isSearching = false
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let plantsCSVString = loadFromCSVFile("plants")
        loadDataFromCSVString(plantsCSVString)
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.search
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Table view data source
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            self.view.endEditing(true)
            tableView.reloadData()
        }
            
        else{
            isSearching = true
            for n in listData{
                names.append(n["name"] as! String)
            }
            
            filtered = names.filter({
                $0.range(of: searchText, options: .caseInsensitive) != nil
            })
            
            tableView.reloadData()
        }
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isSearching{
            print("Filtered Count is \(filtered.count)")
            print("Filtered List is \(filtered)")
            return filtered.count
        }
        
        return listData.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "PlantTableViewCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PlantTableViewCell;
        listData.sort { ($0["name"] as! String) < ($1["name"] as! String) }
        
        
        var item = self.listData[indexPath.row]
        
        if isSearching{
            //    var search = self.filtered[indexPath.row]
            //   print(search)
            cell?.plantName.text = self.filtered[indexPath.row]
            
            for a in listData{
                
                let equal = (a["name"] as! String == filtered[indexPath.row])
                if equal{
                    let url = URL(string: a["img"]  as! String)
                    let request = URLRequest(url: url!)
                    URLSession.shared.dataTask(with: request) {
                        (data, response, error) in
                        DispatchQueue.main.async {
                            cell?.img.image = UIImage(data: data!)
                        }
                        }.resume()
                    
                }
            }
        }
            
            else{
                cell?.plantName.text = item["name"] as? String
                
                let url = URL(string: item["img"]  as! String)
                let request = URLRequest(url: url!)
                URLSession.shared.dataTask(with: request) {
                    (data, response, error) in
                    DispatchQueue.main.async {
                        cell?.img.image = UIImage(data: data!)
                    }
                    }.resume()
            }
            return cell!
        }
        
        
        public func loadFromCSVFile(_ resourcesName: String) -> String {
            guard let csvPath = Bundle.main.path(forResource: resourcesName, ofType: "csv") else {
                fatalError("Unable to load data from \(resourcesName).csv")
            }
            
            let csvString: String
            do {
                csvString = try String(contentsOfFile: csvPath, encoding: String.Encoding.utf8)
            } catch let error {
                fatalError("Error parsing file: \(error)")
            }
            
            return csvString
        }
        
        public func loadDataFromCSVString(_ csvString: String) {
            let csv = CSwiftV(String: csvString)
            
            //  var employees = [Employee]()
            
            for row in csv.keyedRows! {
                data["name"] = row["name"] as AnyObject
                let img = row["imgs-src"]
                data["img"] = "http://www.gardening.cornell.edu/homegardening/\(img!)" as AnyObject
                data["desc"] = row["desc"] as AnyObject
                data["sun"] = row["sunlight"] as AnyObject
                data["soil"] = row["soil"] as AnyObject
                data["maintenance"] = row["maintenance"] as AnyObject
                data["characteristics"] = row["characteristics"] as AnyObject
                
                listData.append(data)
            }
        }
        
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            let index = tableView.indexPathForSelectedRow?.row
            let data =  listData[index!]
            
            if segue.identifier == "next" {
                //Creating an object of the second View controller
                let controller = segue.destination as! PlantDataViewController
                controller.data = data
            }
        }
        
        
}
