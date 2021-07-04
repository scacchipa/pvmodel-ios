import Foundation
import UIKit

class GrapherViewController: UIViewController   {
    var grapherData: GraphData!
    
    init(grapherData: GraphData) {
        self.grapherData = grapherData

        super.init(nibName: nil, bundle: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view = SubLayerView(frame: self.view.bounds, grapherData: grapherData)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func changeGrapherData(_ data: GraphData) {
        self.grapherData = data
        self.view = SubLayerView(frame: self.view.bounds, grapherData: grapherData)
    }
}

class SubLayerView: UIView {
    let textSize:CGFloat = 16
    
    let leftMarginFactor: CGFloat = 0.25
    let rightMarginFactor: CGFloat = 0.05
    let topMarginFactor: CGFloat = 0.01
    let bottomMarginFactor: CGFloat = 0.15
    
    let verticalDivisorCount = 5
    let horizontalDivisorCount = 15
    
    var xScale: CGFloat = 0
    var yScale: CGFloat = 0
    var firstColumnX:CGFloat = 0;
    var secondColumnX:CGFloat = 0;
    
    var firstRowY:CGFloat = 0;
    var secondRowY:CGFloat = 0;
    
    let dxInset: CGFloat = -4
    let dyInset: CGFloat = -4
    
    private var pictureLayers:CAShapeLayer = CAShapeLayer()
    private var curveNameLayers: CATextLayer = CATextLayer()
    private var frameLayer:CAShapeLayer! = CAShapeLayer()
    private var eventLayer:CAShapeLayer! = CAShapeLayer()
    private var hValueLabelLayers: CALayer! = CALayer()
    private var vValueLabelLayers: CALayer! = CALayer()
    private var absLabelLayer:CALayer!
    private var ordLabelLayer:CALayer!
    
    var canvasRect: CGRect = CGRect.zero
    
    let graphData: GraphData!
    
    let labelTextAttirbute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
    let valueTextAttirbute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
    
    init(frame: CGRect, grapherData: GraphData) {
        self.graphData = grapherData
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        canvasRect = CGRect(
            x: bounds.width * leftMarginFactor,
            y: bounds.height * topMarginFactor,
            width: bounds.width * (1 - rightMarginFactor - leftMarginFactor),
            height: bounds.height * (1 - topMarginFactor - bottomMarginFactor))
        
        self.createSubLayers()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateLayers()
    }
    func createSubLayers() {
        
        firstColumnX = canvasRect.origin.x * 0.75
        secondColumnX = canvasRect.origin.x * 0.30
        firstRowY = bounds.height - bounds.height * bottomMarginFactor * 0.20
        secondRowY = bounds.height - bounds.height * bottomMarginFactor * 0.30
        
        xScale = canvasRect.width / graphData.limitRect.width
        yScale = canvasRect.height / graphData.limitRect.height
        
        hValueLabelLayers = CALayer()
        vValueLabelLayers = CALayer()
        absLabelLayer = self.createAbsTitleLayer()
        ordLabelLayer = self.createOrdTitleLayer()

        for idx in 0..<graphData.graphConfig.curveCount() {
            let layer = CAShapeLayer()
            layer.frame = canvasRect
            layer.strokeColor = graphData.graphConfig.curveConfigs[idx].color
            layer.fillColor = UIColor.clear.cgColor
            layer.backgroundColor = UIColor.clear.cgColor
            layer.masksToBounds = true
            pictureLayers.addSublayer(layer)
        }
        
        for idx in 0..<graphData.graphConfig.curveCount() {
            let curveConf = graphData.graphConfig.curveConfigs[idx]
            
            let textLayer = CATextLayer()
            textLayer.string = NSMutableAttributedString(
                string: curveConf.curveTitle,
                attributes: labelTextAttirbute)
            let textFrameSize = textLayer.preferredFrameSize()
            let textRect = CGRect(
                x: canvasRect.maxX - rightMarginFactor * bounds.width - textFrameSize.width,
                y: canvasRect.minX + textFrameSize.height * CGFloat(idx * 2 - 1),
                width: textFrameSize.width,
                height: textFrameSize.height)
            textLayer.foregroundColor = curveConf.color
            textLayer.frame = textRect

            let insetRect = textRect.inset(by: UIEdgeInsets(top: dyInset, left: dxInset, bottom: dyInset, right: dxInset))
            let shapePath = UIBezierPath()
            shapePath.move(to: insetRect.origin)
            shapePath.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.minY))
            shapePath.addLine(to: CGPoint(x: insetRect.maxX, y: insetRect.maxY))
            shapePath.addLine(to: CGPoint(x: insetRect.minX, y: insetRect.maxY))
            shapePath.addLine(to: insetRect.origin)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = shapePath.cgPath
            shapeLayer.strokeColor = graphData.graphConfig.curveConfigs[idx].color
            shapeLayer.fillColor = UIColor.lightGray.cgColor
            
            curveNameLayers.addSublayer(shapeLayer)
            curveNameLayers.addSublayer(textLayer)
        }
        
        self.layer.addSublayer(frameLayer)
        self.layer.addSublayer(pictureLayers)
        self.layer.addSublayer(eventLayer)
        self.layer.addSublayer(curveNameLayers)
        self.clipsToBounds = true
        self.layer.addSublayer(absLabelLayer)
        self.layer.addSublayer(ordLabelLayer)
    }
    private func addCGPoint(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
         return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
    }
    
    func createAbsTitleLayer() -> CALayer! {
        let layer = CATextLayer()
        layer.string = NSMutableAttributedString(
            string: graphData.graphConfig.abscissaTitle + "(" + graphData.graphConfig.abscissaMagnitude + ")",
            attributes: labelTextAttirbute)
        let absFrameSize = layer.preferredFrameSize()
        layer.frame = CGRect(x: canvasRect.midX - absFrameSize.width / 2, y: secondRowY - absFrameSize.height / 2, width:absFrameSize.width, height:absFrameSize.height)
        return layer
    }
    func createOrdTitleLayer() -> CALayer! {
        let layer = CATextLayer()
        layer.string = NSMutableAttributedString(
            string: graphData.graphConfig.ordenateTitle  + "("+graphData.graphConfig.ordenateMagnitude+")",
            attributes: labelTextAttirbute)
        let ordFrameSize = layer.preferredFrameSize()
        layer.frame = CGRect(x:secondColumnX - ordFrameSize.width / 2, y:canvasRect.midY - ordFrameSize.height / 2, width:ordFrameSize.width, height:ordFrameSize.height)
        layer.alignmentMode = CATextLayerAlignmentMode.center
        
        layer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        return layer
    }
    func updateFrameLayer() {
        let framePath = UIBezierPath()
        
        // draw frame
        framePath.move(to: CGPoint(x: canvasRect.origin.x, y: canvasRect.origin.y))
        framePath.addLine(to: CGPoint(x: canvasRect.origin.x, y: canvasRect.maxY))
        framePath.addLine(to: CGPoint(x: canvasRect.maxX, y: canvasRect.maxY))
        framePath.addLine(to: CGPoint(x: canvasRect.maxX, y: canvasRect.origin.y))
        framePath.addLine(to: CGPoint(x: canvasRect.origin.x, y: canvasRect.origin.y))

        // draw vertical divisor
        let yOnset = canvasRect.origin.y
        let yOffset = canvasRect.origin.y + canvasRect.size.height
        let ySeparation = canvasRect.size.height / CGFloat(verticalDivisorCount)
        for posY in stride(from: yOnset, to: yOffset, by: ySeparation) {
            framePath.move(to: CGPoint(x: canvasRect.origin.x, y: posY))
            framePath.addLine(to: CGPoint(x:canvasRect.origin.x - 5, y: posY))
        }

        let tempoSeparation = graphData.limitRect.width / CGFloat(horizontalDivisorCount)
        let firstDivNumber = (graphData.limitRect.origin.x / tempoSeparation).rounded()
        
        // draw horizontal divisor
        for idx in 1..<horizontalDivisorCount {
            let realDivNumber = firstDivNumber + CGFloat(idx)
            let tempoToMark = tempoSeparation * CGFloat(realDivNumber)
            let posX = canvasRect.origin.x + (tempoToMark - graphData.limitRect.origin.x ) * xScale
            let posY = canvasRect.maxY
            framePath.move(to: CGPoint(x: posX, y: posY))
            framePath.addLine(to: CGPoint(x: posX, y: posY + 5))
        }
    
        frameLayer.fillColor = UIColor.clear.cgColor
        frameLayer.strokeColor = UIColor.black.cgColor
        frameLayer.frame = self.bounds
        frameLayer.masksToBounds = true
        frameLayer.path = framePath.cgPath
        
        // write horizontal value labels
        hValueLabelLayers.removeFromSuperlayer()
        hValueLabelLayers = CALayer()
        hValueLabelLayers.frame = CGRect(x: canvasRect.origin.x, y: canvasRect.maxY + 5, width: canvasRect.size.width, height: 30)
        hValueLabelLayers.masksToBounds = true
        
        for idx in -4..<(horizontalDivisorCount + 3) {
            let realDivNumber = firstDivNumber + CGFloat(idx)
            
            if (realDivNumber.truncatingRemainder(dividingBy: 4) == 0) {
                let valueLayer = CATextLayer()
                let tempoToWrite = tempoSeparation * CGFloat(realDivNumber)
                valueLayer.string = NSAttributedString(
                    string: String(format: "%.0f", tempoToWrite),
                    attributes: valueTextAttirbute)
                valueLayer.frame = CGRect(
                    x: (tempoToWrite - graphData.limitRect.origin.x) * xScale,
                    y: 0,
                    width: valueLayer.preferredFrameSize().width,
                    height: valueLayer.preferredFrameSize().height)
                
                hValueLabelLayers.addSublayer(valueLayer)
            }
        }
        //hValueLabelLayers.transform = CATransform3DMakeTranslation(0, 5, 0)
        self.layer.addSublayer(hValueLabelLayers)
        
        // write vertical value labels
        vValueLabelLayers.removeFromSuperlayer()
        vValueLabelLayers = CALayer()
        vValueLabelLayers.frame = CGRect(x: canvasRect.origin.x * 0.6 - 5, y: canvasRect.origin.y, width: canvasRect.origin.x * 0.4, height: canvasRect.height)
        vValueLabelLayers.masksToBounds = true
        
        for idx in 1...verticalDivisorCount {
            let valueLayer = CATextLayer()
            valueLayer.string = NSAttributedString(
                string: String(format: "%.0f", CGFloat(verticalDivisorCount - idx) * ySeparation / yScale),
                attributes: valueTextAttirbute)
            valueLayer.frame = CGRect(
                x: vValueLabelLayers.frame.width - valueLayer.preferredFrameSize().width,
                y: ySeparation * CGFloat(idx) - valueLayer.preferredFrameSize().height,
                width: valueLayer.preferredFrameSize().width,
                height: valueLayer.preferredFrameSize().height)
            vValueLabelLayers.addSublayer(valueLayer)
        }
        self.layer.addSublayer(vValueLabelLayers)
    }

    func updateLayers() {
        self.updatePictureLayers()
        self.updateFrameLayer()
        self.updateEventLayer()
    }
    func updatePictureLayers() {
        self.graphData.semaphore.wait()
        
        for idx in 0..<graphData.pointVector.count {
            let pointList = graphData.pointVector[idx]
            if pointList.count > 0 {
                let picturePath = UIBezierPath()
                
                picturePath.move(to: pointList.first!)
                for point in pointList {
                    picturePath.addLine(to: point)
                }
                
                picturePath.apply(CGAffineTransform(scaleX: 1.0, y: -1.0))
                picturePath.apply(CGAffineTransform(translationX: -graphData.limitRect.origin.x, y: graphData.limitRect.maxY))
                picturePath.apply(CGAffineTransform(scaleX: xScale, y: yScale))
                (pictureLayers.sublayers![idx] as! CAShapeLayer).path = picturePath.cgPath
            }
        }
        self.graphData.semaphore.signal()
    }
    private func updateEventLayer() {
        let eventPath = UIBezierPath()
        
        self.graphData.semaphore.wait()
        for pointList in self.graphData.pointVector {
            if pointList.count > 0 {
                let center = CGPoint(
                    x: (pointList.last!.x - graphData.limitRect.origin.x) * xScale,
                    y: (graphData.limitRect.maxY - pointList.last!.y) * yScale)
                eventPath.move(to: center)
                eventPath.addArc(
                    withCenter: center,
                    radius: 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
            }
        }
        self.graphData.semaphore.signal()

        eventLayer.fillColor = UIColor.blue.cgColor
        eventLayer.strokeColor = UIColor.blue.cgColor
        eventLayer.frame = canvasRect
        eventLayer.masksToBounds = true
        eventLayer.path = eventPath.cgPath
        
    }
}
