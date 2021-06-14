import Foundation
import UIKit

class GrapherView: UIView   {
    var graphConfig: GraphConfig? = nil
    var grapherData: GrapherData? = nil
    let textSize:CGFloat = 16
    let leftMargin:CGFloat = 90
    let rightMargin:CGFloat = 10
    let topMargin:CGFloat = 10
    let bottonMargin:CGFloat = 60
    
    let verticalDivisorCount = 5
    let horizontalDivisorCount = 15
    
    var firstColumnX:CGFloat = 0;
    var secondColumnX:CGFloat = 0;
    
    var firstRowY:CGFloat = 0;
    var secondRowY:CGFloat = 0;
    
    var canvasRect: CGRect = CGRect.zero
    
    private var pictureLayer:CAShapeLayer! = CAShapeLayer()
    private var frameLayer:CALayer!
    private var absLabelLayer:CALayer!
    private var ordLabelLayer:CALayer!
    
    private var pointVector:[CGPoint] = [CGPoint]()
    private var cavity: Cavity? = nil
    
    private var parent:ModelViewController?
    
    init(frame: CGRect, graphConfig: GraphConfig, grapherData: GrapherData) {
        self.graphConfig = graphConfig
        self.grapherData = grapherData
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override func draw(_ rect: CGRect) {
        self.updatePictureLayer()
        super.draw(rect)
    }
    
    func createSubLayers() {
        canvasRect = CGRect(x: leftMargin, y: topMargin, width: bounds.size.width - rightMargin - leftMargin, height: bounds.size.height - bottonMargin - topMargin)
        firstColumnX = leftMargin * 0.75
        secondColumnX = leftMargin * 0.30
        firstRowY = self.bounds.size.height - bottonMargin * 0.75
        secondRowY = self.bounds.size.height - bottonMargin * 0.30
        
        pictureLayer = self.createPictureLayer()
        frameLayer = self.createFrameLayer()
        absLabelLayer = self.createAbsTitleLayer()
        ordLabelLayer = self.createOrdTitleLayer()

        self.layer.addSublayer(frameLayer)
        self.layer.addSublayer(pictureLayer)
        self.clipsToBounds = true
        self.layer.addSublayer(absLabelLayer)
        self.layer.addSublayer(ordLabelLayer)
        
    }
    func createFrameLayer() -> CALayer! {
        let framePath = UIBezierPath()
        framePath.move(to: CGPoint(x: canvasRect.origin.x, y: canvasRect.origin.y))
        framePath.addLine(to: CGPoint(x: canvasRect.origin.x, y: canvasRect.maxY))
        framePath.addLine(to: CGPoint(x: canvasRect.maxX, y: canvasRect.maxY))
        framePath.addLine(to: CGPoint(x: canvasRect.maxX, y: canvasRect.origin.y))
        framePath.addLine(to: CGPoint(x: canvasRect.origin.x, y: canvasRect.origin.y))
       
        let yOnset = canvasRect.origin.y
        let yOffset = canvasRect.origin.y + canvasRect.size.height
        let ySeparation = canvasRect.size.height / CGFloat(verticalDivisorCount)
        for posY in stride(from:Float(yOnset), to:Float(yOffset), by:Float(ySeparation)) {
            framePath.move(to: CGPoint(x: canvasRect.origin.x, y: CGFloat(posY)))
            framePath.addLine(to: CGPoint(x:canvasRect.origin.x - 10, y:CGFloat(posY)))
        }

        let xOnset = canvasRect.origin.x
        let xOffset = canvasRect.origin.x + canvasRect.size.width
        let xSeparation = canvasRect.size.width / CGFloat(horizontalDivisorCount)
        for posX in stride(from:Float(xOnset), to:Float(xOffset), by:Float(xSeparation)) {
            framePath.move(to: CGPoint(x: CGFloat(posX), y: canvasRect.origin.y + canvasRect.size.height))
            framePath.addLine(to: CGPoint(x:CGFloat(posX), y: canvasRect.origin.y + canvasRect.size.height + 10))
        }

        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.black.cgColor
        layer.frame = self.bounds
        layer.masksToBounds = true
        layer.path = framePath.cgPath
        
        return layer
    }
    func createPictureLayer() -> CAShapeLayer! {
        return CAShapeLayer()
    }
    func updatePictureLayer() {
        let picturePath = UIBezierPath()
        
        parent?.semaphore?.wait()
        
        if pointVector.count > 0 {
            picturePath.move(to: pointVector[0])
            for point in pointVector {
                picturePath.addLine(to: point)
            }
        }
        parent?.semaphore?.signal()
        
        picturePath.apply(CGAffineTransform(scaleX: 1.0, y: -1.0))
        picturePath.apply(CGAffineTransform(translationX: 0, y: canvasRect.size.height))
        pictureLayer.fillColor = UIColor.clear.cgColor
        pictureLayer.strokeColor = UIColor.blue.cgColor
        pictureLayer.frame = canvasRect
        pictureLayer.masksToBounds = true
        pictureLayer.path = picturePath.cgPath
        
    }
    func createAbsTitleLayer() -> CALayer! {
        let layer = CATextLayer()
        layer.string = NSMutableAttributedString(string: "Abscisas", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.textSize)])
        let absFrameSize = layer.preferredFrameSize()
        layer.frame = CGRect(x: canvasRect.midX - absFrameSize.width / 2, y: secondRowY - absFrameSize.height / 2, width:absFrameSize.width, height:absFrameSize.height)
        return layer
    }
    func createOrdTitleLayer() -> CALayer! {
        let layer = CATextLayer()
        layer.string = NSMutableAttributedString(string: "Ordenadas", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.textSize)])
        let ordFrameSize = layer.preferredFrameSize()
        layer.frame = CGRect(x:secondColumnX - ordFrameSize.width / 2, y:canvasRect.midY - ordFrameSize.height / 2, width:ordFrameSize.width, height:ordFrameSize.height)
        layer.alignmentMode = CATextLayerAlignmentMode.center
        
        layer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        return layer
    }
    func clearPointVector() {
        pointVector = [CGPoint]()
    }
    func addPoint(point:CGPoint) {
        pointVector.append(point)
        if pointVector.count > 500 {
            pointVector.removeFirst()
        }
    }
    func setCavity(cavity:Cavity) {
        self.cavity = cavity
    }
    func updateValue() {
        self.addPoint(point:CGPoint(x:cavity!.volumen, y:cavity!.pressure))
    }
    func setParent(parent:ModelViewController?) {
        self.parent = parent;
    }
}

class LoopPVGrapherView: GrapherView {
    init(frame:CGRect, data: GrapherData) {
        super.init(
            frame: frame,
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
                ]),
            grapherData: data)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FadeXYGrapherView: GrapherView {
    override init(frame:CGRect, graphConfig: GraphConfig, grapherData: GrapherData) {
        super.init(frame: frame, graphConfig: graphConfig, grapherData: grapherData)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class PresionEnTiempoGrapherView: FadeXYGrapherView {
    init(frame:CGRect, data: GrapherData) {
        super.init(
            frame: frame,
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
                ]),
                grapherData: data)
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VolumenEnTiempoGrapherView: FadeXYGrapherView {
    init (frame:CGRect, data: GrapherData) {
        super.init(
            frame: frame,
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
                            y: CGFloat(heart.leftAtrium.volumen))] } ) ]),
            grapherData: data)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TensionGrapherView: GrapherView {
    init(frame: CGRect, data: GrapherData) {
        super.init(
            frame: frame,
            graphConfig: GraphConfig(
                abscissaTitle: "Volume",
                abscissaMagnitude: "mL",
                ordenateTitle: "Pressure",
                ordenateMagnitude: "mmHg",
                curveConfigs: [
                    CurveConfig(
                        curveTitle: "VMax-LV",
                        color: UIColor.blue.cgColor,
                        addingFunction: { heart in return (Int(0)..<Int(10)).map { return CGPoint(
                            x: CGFloat($0 * 20),
                            y: CGFloat(heart.leftVentricle.getIntrinsicPressure(volumen: Double($0 * 20)))) } } ),
                    CurveConfig(
                        curveTitle: "VMax-LA",
                        color: UIColor.red.cgColor,
                        addingFunction: { heart in return (Int(0)..<Int(10)).map { CGPoint(
                            x: CGFloat($0 * 20),
                            y: CGFloat(heart.leftAtrium.getIntrinsicPressure(volumen:Double($0 * 20)))) } } ) ]),
            grapherData: data)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
