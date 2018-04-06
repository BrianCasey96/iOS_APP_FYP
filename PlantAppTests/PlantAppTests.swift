//
//  PlantAppTests.swift
//  PlantAppTests
//
//  Created by Casey, Brian on 12/01/2017.
//  Copyright © 2017 Casey, Brian. All rights reserved.
//

import XCTest
@testable import PlantApp

let dateformatter = DateFormatter()

class PlantAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testReturnExpectedValues(){
        
        let x = ["time_value":"2018-03-04T13:33:25.000Z","moisture":52,"temp":17.75,"light":66.4617] as [String : Any]
        
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let value = x["time_value"]
        print(value as Any)
        let a = (value as AnyObject).replacingOccurrences(of: "T", with: " ")
        let b = a.replacingOccurrences(of: ".000Z", with: "")

        let date = dateformatter.date(from: b)
        let compareDate = dateformatter.date(from: "2018-03-04 13:33:25")
        
        let m = x["moisture"] as! Int
        let t = x["temp"] as! Double
        let l = x["light"] as! Double
    
        XCTAssertEqual(m, 52)
        XCTAssertEqual(t, 17.75)
        XCTAssertEqual(l, 66.4617)
        XCTAssertEqual(date, compareDate)
        
    }
    
    func testValidCallTo_APIAllData_GetsHTTPStatusCode200() {
        let url = URL(string: "http://35.198.67.227:8080/allData")
        let promise = expectation(description: "Status code: 200")
        
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }).resume()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testValidCallTo_APITopValue_GetsHTTPStatusCode200() {
        let url = URL(string: "http://35.198.67.227:8080/top")
        let promise = expectation(description: "Status code: 200")

        
        URLSession.shared.dataTask(with: url!, completionHandler: {
            (data, response, error) in
            
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }).resume()
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSortDatabyDate(){
        
    }
   
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

