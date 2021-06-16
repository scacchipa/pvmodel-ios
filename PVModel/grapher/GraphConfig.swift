
import Foundation
import UIKit

struct GraphConfig {
    var abscissaTitle: String
    var abscissaMagnitude: String
    var ordenateTitle: String
    var ordenateMagnitude: String
    var curveConfigs: [CurveConfig]
    
    init(abscissaTitle: String, abscissaMagnitude: String, ordenateTitle: String, ordenateMagnitude: String, curveConfigs: [CurveConfig]) {
        self.abscissaTitle = abscissaTitle
        self.abscissaMagnitude = abscissaMagnitude
        self.ordenateTitle = ordenateTitle
        self.ordenateMagnitude = ordenateMagnitude
        self.curveConfigs = curveConfigs
    }
    
    func curveCount() -> Int {
        return curveConfigs.count
    }
}

struct CurveConfig {
    var curveTitle: String
    var color: CGColor
    var addingFunction: (Heart) -> [CGPoint]
    init(curveTitle: String, color: CGColor, addingFunction: @escaping (Heart) -> [CGPoint]) {
        self.curveTitle = curveTitle
        self.color = color
        self.addingFunction = addingFunction
    }
}
