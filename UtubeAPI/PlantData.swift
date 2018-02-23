import Foundation
import CoreLocation

struct PlantData {

    let moisture: Int
    let temp: Double
    let light: Double
    let date: String

    init(moisture: Int, temp: Double, light: Double, date: String) {
        self.moisture = moisture
        self.temp = temp
        self.light = light
        self.date = date
    }
}



