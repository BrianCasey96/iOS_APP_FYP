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
    
    func refreshFromServer() -> [PlantData]{
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
                    self.plant_data = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [PlantData]
                    
                    DispatchQueue.main.async() { () -> Void in
                        
                        print(self.plant_data)
                     //   self.tableView.reloadData()
                     //   self.refresh.endRefreshing()
                        
                    }
                }catch let error as NSError{
                    print(error)
                }
            }
        }).resume()
        
        return self.plant_data
    }

    
}
