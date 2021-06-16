import Foundation
import UIKit

public class GrapherData {
    var source: Heart
    var limitRect: CGRect
    var xShift:CGFloat = 0
    var pointVector: [[CGPoint]] = []
    var _grapherView: GrapherViewController?
    var grapherView: GrapherViewController?{
        get {
            return self.grapherView
        }
        set(value) {
            if (value?.graphConfig == nil) {
                self.pointVector = []
            } else {
                self.pointVector = [ [CGPoint] ](repeating:[CGPoint](), count:(grapherView!.graphConfig!.curveCount()) )
                self._grapherView = grapherView
            }
        }
    }
    init(source: Heart, limitRect: CGRect) {
        self.source = source
        self.limitRect = limitRect
    }
    func updateValue() {
        if (grapherView != nil) {
            let points:[[CGPoint]] = (grapherView!.graphConfig!.curveConfigs.map {
                $0.addingFunction(self.source)
            })
            self.addValues(points:points)
        }
    }
    func addValues(points: [[CGPoint]]) {
        for (idx, var array) in pointVector.enumerated(){
            array.append(contentsOf:points[idx])
        }
        shiftOnset()
    }
    func shiftOnset() {
        for var points in pointVector {
            if (points.count > 500) {
                points.remove(at:0)
            }
        }
    }
    func clear() {
        for var points in pointVector {
            points.removeAll()
        }
    }

    func isEmpty() -> Bool {
        return pointVector.count == 0
    }
    func size() -> Int {
        return pointVector.count
    }
}

class FadeXYGrapherData: GrapherData {
    override init(source: Heart, limitRect: CGRect) {
        super.init(source:source, limitRect: limitRect)
    }
        
    override func shiftOnset() {
        if (pointVector.count > 0) {
            let tempXShift = max(xShift, pointVector.last!.last!.x - limitRect.maxX)
            for var points in pointVector {
                if (points.first!.x < CGFloat(xShift) - limitRect.maxX) {
                    points.remove(at:0)
                }
            }
            xShift = tempXShift
        }
    }
}
class TensionGrapherData: GrapherData {
    init(source: Heart) {
        super.init(source:source, limitRect: CGRect(x: 0, y: 200, width: 200, height: -50))
    }
        
    override func updateValue() {
        if (grapherView != nil) {
            clear()
            let points: [[CGPoint]] = (grapherView!.graphConfig!.curveConfigs.map {
                    $0.addingFunction(self.source)
                })
            addValues(points:points)
        }
    }
    override func shiftOnset() {
    }
}

class PresionEnTiempoGrapherData: FadeXYGrapherData{
    init(source: Heart) {
        super.init(source: source, limitRect: CGRect(x: 0, y: 170, width: 3000, height: -10))
    }
}

class VolumenEnTiempoGrapherData: FadeXYGrapherData {
    init(source: Heart) {
        super.init(source: source, limitRect: CGRect(x: 0, y: 170, width: 3000, height: -10))
    }
}
class LoopPVGrapherData: GrapherData{
    init(source: Heart) {
        super.init(source: source, limitRect: CGRect(x: 0, y: 150, width: 200, height: 0))
    }
}
