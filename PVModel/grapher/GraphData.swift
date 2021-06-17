import Foundation
import UIKit

public class GraphData {
    var source: Heart
    var limitRect: CGRect
    var pointVector: [[CGPoint]] = []
    var semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    var graphConfig: GraphConfig
    
    init(source: Heart, limitRect: CGRect, graphConfig: GraphConfig) {
        self.source = source
        self.limitRect = limitRect
        self.graphConfig = graphConfig
        self.pointVector = [[CGPoint]](repeating: [CGPoint](), count: graphConfig.curveCount())
    }
    func updateValue() {
        let points:[[CGPoint]] = graphConfig.curveConfigs.map {
            $0.addingFunction(self.source)
        }
        self.addValues(points:points)
    }
    func addValues(points: [[CGPoint]]) {
        for idx in 0..<points.count {
            pointVector[idx].append(contentsOf:points[idx])
        }
        shiftOnset()
    }
    func shiftOnset() {
        for idx in 0..<pointVector.count {
            if (pointVector[idx].count > 500) {
                pointVector[idx].remove(at:0)
            }
        }
    }
    func clear() {
        for idx in 0..<pointVector.count{
            pointVector[idx].removeAll()
        }
    }

    func isEmpty() -> Bool {
        return pointVector.count == 0
    }
    func size() -> Int {
        return pointVector.count
    }
}

class FadeXYGrapherData: GraphData {
    override init(source: Heart, limitRect: CGRect, graphConfig: GraphConfig) {
        super.init(source:source, limitRect: limitRect, graphConfig: graphConfig)
    }
        
    override func shiftOnset() {
        if (pointVector.count > 0) {
            if (pointVector.first!.count > 0) {
                limitRect.origin.x = max(limitRect.minX, pointVector.last!.last!.x - limitRect.maxX)
                for idx in 0..<pointVector.count {
                    if (pointVector[idx].first!.x < limitRect.origin.x) {
                        pointVector[idx].remove(at:0)
                    }
                }
            }
        }
    }
}

class TensionGrapherData: GraphData {
    init(source: Heart) {
        super.init(
            source: source,
            limitRect: CGRect(x: 0, y: -50, width: 200, height: 160),
            graphConfig: GraphConfig(
                abscissaTitle: "Volume",
                abscissaMagnitude: "mL",
                ordenateTitle: "Pressure",
                ordenateMagnitude: "mmHg",
                curveConfigs: [
                   CurveConfig(
                       curveTitle: "VMax-LV",
                       color: UIColor.blue.cgColor,
                       addingFunction: { heart in return (Int(0)..<Int(10)).map {
                        let x = CGFloat($0 * 20)
                        var y = CGFloat(heart.leftVentricle.getIntrinsicPressure(volumen: Double($0 * 20)))
                        if y.isInfinite {
                            if (y.sign == .plus) {
                                y = 400
                            } else {
                                y = -400
                            }
                        }
                        return CGPoint(x: x,y: y) } }),
                   CurveConfig(
                       curveTitle: "VMax-LA",
                       color: UIColor.red.cgColor,
                       addingFunction: { heart in return (Int(0)..<Int(10)).map {
                        let x = CGFloat($0 * 20)
                        var y = CGFloat(heart.leftAtrium.getIntrinsicPressure(volumen: Double($0 * 20)))
                        if y.isInfinite {
                            if (y.sign == .plus) {
                                y = 400
                            } else {
                                y = -400
                            }
                        }
                        return CGPoint(x: x,y: y) } } )
                ]))
    }
        
    override func updateValue() {
        clear()
        let points: [[CGPoint]] = graphConfig.curveConfigs.map {
                $0.addingFunction(self.source)
            }
        addValues(points:points)
    }
    override func shiftOnset() {
    }
}

class PresionEnTiempoGrapherData: FadeXYGrapherData {
    init(source: Heart) {
        super.init(
            source: source,
            limitRect: CGRect(x: 0, y: -10, width: 3000, height: 180),
            graphConfig: GraphConfig(
                abscissaTitle: "Time",
                abscissaMagnitude: "s",
                ordenateTitle: "Pressure",
                ordenateMagnitude: "mmHg",
                curveConfigs:[
                   CurveConfig(
                       curveTitle: "LV",
                       color: UIColor.blue.cgColor,
                       addingFunction: { heart in return [CGPoint(
                           x: CGFloat(heart.clock.time),
                           y: CGFloat(heart.leftVentricle.pressure))] }),
                   CurveConfig(
                       curveTitle: "Ao",
                       color: UIColor.gray.cgColor,
                       addingFunction: { heart in return [CGPoint(
                           x: CGFloat(heart.clock.time),
                           y: CGFloat(heart.aorta.pressure))] }),
                   CurveConfig(
                       curveTitle: "LA",
                       color: UIColor.red.cgColor,
                       addingFunction:{ heart in return [CGPoint(
                           x: CGFloat(heart.clock.time),
                           y: CGFloat(heart.leftAtrium.pressure))] } )
                ]))
    }
}

class VolumenEnTiempoGrapherData: FadeXYGrapherData {
 
    init(source: Heart) {
        super.init(
            source: source,
            limitRect: CGRect(x: 0, y: -10, width: 3000, height: 180),
            graphConfig: GraphConfig(
                abscissaTitle: "Time",
                abscissaMagnitude: "s",
                ordenateTitle: "Volume",
                ordenateMagnitude: "mL",
                curveConfigs: [
                   CurveConfig(
                       curveTitle: "LV",
                       color: UIColor.blue.cgColor,
                       addingFunction: { heart in return [CGPoint(
                           x: CGFloat(heart.clock.time),
                           y: CGFloat(heart.leftVentricle.volumen))] }),
                   CurveConfig(
                       curveTitle: "LA",
                       color: UIColor.red.cgColor,
                       addingFunction: { heart in return [CGPoint(
                           x: CGFloat(heart.clock.time),
                           y: CGFloat(heart.leftAtrium.volumen))] } ) ]))
    }
}
class LoopPVGrapherData: GraphData{
    init(source: Heart) {
        super.init(
            source: source,
            limitRect: CGRect(x: 0, y: 0, width: 200, height: 160),
            graphConfig: GraphConfig(
                abscissaTitle:"Volume",
                abscissaMagnitude:"mL",
                ordenateTitle:"Pressure",
                ordenateMagnitude:"mmHg",
                curveConfigs: [
                   CurveConfig(
                       curveTitle:"LV",
                       color: UIColor.blue.cgColor,
                       addingFunction: { heart in return [CGPoint(
                           x: heart.leftVentricle.volumen,
                           y: heart.leftVentricle.pressure)] }),
                   CurveConfig(
                       curveTitle:"LA",
                       color: UIColor.red.cgColor,
                       addingFunction: { heart in return [CGPoint(
                           x: heart.leftAtrium.volumen,
                           y: heart.leftAtrium.pressure)] })
                ]))
    }
}
