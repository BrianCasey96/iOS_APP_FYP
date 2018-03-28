//
//  ChartViewController.swift
//  UtubeAPI
//
//  Created by Casey, Brian on 21/03/2018.
//  Copyright © 2018 Casey, Brian. All rights reserved.
//

import UIKit
import Charts

class ChartViewController: UIViewController {

    var values: [[String:AnyObject]]?
    
    @IBOutlet var chartView: LineChartView!
    let dateformatter = DateFormatter()
    
    @IBOutlet var tempChartView: LineChartView!
    @IBOutlet var lightChartView: LineChartView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var popUpView: UIView!
    @IBOutlet var popUpView2: UIView!
    @IBOutlet var popUpView3: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpView.layer.cornerRadius = 10
        popUpView2.layer.cornerRadius = 10
        popUpView3.layer.cornerRadius = 10


        scrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height+2000)
        
        updateChart()
        chartView.setScaleEnabled(true)
        
        chartView.animate(xAxisDuration: 2.5)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func dismissPopover(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func updateChart() {
        var chart_temp_Entry = [ChartDataEntry]()
        var chart_moist_Entry = [ChartDataEntry]()
        var chart_light_Entry = [ChartDataEntry]()
        
        values = values?.reversed()
        
        if let filteredList = values{
            for i in 0..<filteredList.count{
                
                let temp = filteredList[i]["temp"] as! Double
                let value_temp = ChartDataEntry(x: Double(i), y: temp )
                chart_temp_Entry.append(value_temp)
                
                let moist = filteredList[i]["moisture"] as! Double
                let value_moist = ChartDataEntry(x: Double(i), y: moist )
                chart_moist_Entry.append(value_moist)
                
                let light = filteredList[i]["light"] as! Double
                let value_light = ChartDataEntry(x: Double(i), y: light )
                chart_light_Entry.append(value_light)
            }
        }

        
        let templine = LineChartDataSet(values: chart_temp_Entry, label: "Temperature °C")
        let moistline = LineChartDataSet(values: chart_moist_Entry, label: "Moisture%")
        let lightline = LineChartDataSet(values: chart_light_Entry, label: "Light%")
        
        
        templine.colors = [UIColor.yellow]
        lightline.colors = [UIColor.red]
         moistline.colors = [UIColor.blue]
        
        
        let data = LineChartData()
     //   data.addDataSet(templine)
        data.addDataSet(moistline)
      //  data.addDataSet(lightline)
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: getTimes().reversed())
        chartView.xAxis.granularity = 1
        chartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        chartView.data = data
        chartView.chartDescription?.text = "DAY"
        
        let ldata = LineChartData()
        ldata.addDataSet(lightline)
        lightChartView.data = ldata
        lightChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: getTimes().reversed())
        lightChartView.xAxis.granularity = 1
        lightChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        let tdata = LineChartData()
        tdata.addDataSet(templine)
        tempChartView.data = tdata
        tempChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: getTimes().reversed())
        tempChartView.xAxis.granularity = 1
        tempChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        
        
    }

    
    func getTimes() -> [String]{
        
        var times = [String]()
        
        if let filteredList = values {
            for i in 0..<filteredList.count {
                
                dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let day = filteredList[i]["time_value"] as! String? ?? "nil"
                let a = day.replacingOccurrences(of: "T", with: " ")
                let b = a.replacingOccurrences(of: ".000Z", with: "")
                let date = dateformatter.date(from: b)
                dateformatter.dateFormat = "HH:mm"
                let time = dateformatter.string(from: date!)

                times.append(time)
            }
        }
        return times
    }

}
