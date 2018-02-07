//
//  getData.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 27/01/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import Foundation
import UIKit

class getData {
    
    var plant_data = [PlantData]()
    var listData = [[String: AnyObject]]()
    
    func refreshDataFromServer(){
        // refresh.beginRefreshing()
        // tableView.delegate = self
        // tableView.dataSource = self
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
                        
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
        
    }
    
    
    func populatePlantData() -> [PlantData]{
       // refreshFromServer()
        print(self.listData)
        print("Hello")
    
        //        print(listData)
        //        print(xo)
      print(self.listData.count)
            for row in self.listData{
                
                let m = row["Moisture"] as! String?
                let t = row["Temp"] as! String?
                let l = row["Light"] as! String?
                let d = row["Date"] as! String?
                
                print("Row is \(row)")
                
                
                let data = PlantData(moisture: m!,
                                     temp: t!,
                                     light: l!,
                                     date: d!)
                
                self.plant_data.append(data)
            
        }
        return self.plant_data
    }
    
}

