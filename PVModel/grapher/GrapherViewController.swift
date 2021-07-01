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
    let leftMargin:CGFloat = 90
    let rightMargin:CGFloat = 10
    let topMargin:CGFloat = 10
    let bottonMargin:CGFloat = 60
    
    let verticalDivisorCount = 5
    let horizontalDivisorCount = 15
    
    var xScale: CGFloat = 0
    var yScale: CGFloat = 0
    var firstColumnX:CGFloat = 0;
    var secondColumnX:CGFloat = 0;
    
    var firstRowY:CGFloat = 0;
    var secondRowY:CGFloat = 0;
    
    private var pictureLayer:CAShapeLayer! = CAShapeLayer()
    private var frameLayer:CAShapeLayer! = CAShapeLayer()
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
        self.backgroundColor = UIColor.yellow
        
        canvasRect = CGRect(x: leftMargin, y: topMargin, width: self.bounds.size.width - rightMargin - leftMargin, height: self.bounds.size.height - bottonMargin - topMargin)
        
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
        
        firstColumnX = leftMargin * 0.75
        secondColumnX = leftMargin * 0.30
        firstRowY = bottonMargin * 0.20
        secondRowY = self.bounds.size.height - bottonMargin * 0.30
        
        xScale = canvasRect.width / graphData.limitRect.width
        yScale = canvasRect.height / graphData.limitRect.height
        
        pictureLayer = CAShapeLayer()
        frameLayer = CAShapeLayer()
        hValueLabelLayers = CALayer()
        vValueLabelLayers = CALayer()
        absLabelLayer = self.createAbsTitleLayer()
        ordLabelLayer = self.createOrdTitleLayer()

        
        self.layer.addSublayer(frameLayer)
        self.layer.addSublayer(pictureLayer)
        self.clipsToBounds = true
        self.layer.addSublayer(absLabelLayer)
        self.layer.addSublayer(ordLabelLayer)
        
    }
    func createAbsTitleLayer() -> CALayer! {
        let layer = CATextLayer()
        layer.string = NSMutableAttributedString(
            string: graphData.graphConfig.abscissaTitle + "(" + graphData.graphConfig.abscissaMagnitude + ")",
            attributes: labelTextAttirbute)
        let absFrameSize = layer.preferredFrameSize()
        layer.frame = CGRect(x: bounds.midX - absFrameSize.width / 2, y: secondRowY - absFrameSize.height / 2, width:absFrameSize.width, height:absFrameSize.height)
        return layer
    }
    func createOrdTitleLayer() -> CALayer! {
        let layer = CATextLayer()
        layer.string = NSMutableAttributedString(
            string: graphData.graphConfig.ordenateTitle  + "("+graphData.graphConfig.ordenateMagnitude+")",
            attributes: labelTextAttirbute)
        let ordFrameSize = layer.preferredFrameSize()
        layer.frame = CGRect(x:secondColumnX - ordFrameSize.width / 2, y:bounds.midY - ordFrameSize.height / 2, width:ordFrameSize.width, height:ordFrameSize.height)
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
            framePath.move(to: CGPoint(
                    x: posX,
                    y: posY))
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
        hValueLabelLayers.frame = CGRect(x: canvasRect.origin.x, y: canvasRect.maxY, width: canvasRect.size.width, height: 30)
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
                    x: (tempoToWrite - graphData.limitRect.origin.x ) * xScale,
                    y: 0,
                    width: valueLayer.preferredFrameSize().width,
                    height: valueLayer.preferredFrameSize().height)
                
                hValueLabelLayers.addSublayer(valueLayer)
            }
        }
        hValueLabelLayers.transform = CATransform3DMakeTranslation(0, firstRowY, 0)
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
        self.updatePictureLayer()
        self.updateFrameLayer()
    }
    func updatePictureLayer() {
        let picturePath = UIBezierPath()

        self.graphData.semaphore.wait()
        for pointList in self.graphData.pointVector {
            if pointList.count > 0 {
                picturePath.move(to: pointList.first!)
                for point in pointList {
                    picturePath.addLine(to: point)
                }
            }
        }
        self.graphData.semaphore.signal()
        
        
        
        picturePath.apply(CGAffineTransform(scaleX: 1.0, y: -1.0))
        picturePath.apply(CGAffineTransform(translationX: -graphData.limitRect.origin.x, y: graphData.limitRect.maxY))
        picturePath.apply(CGAffineTransform(scaleX: xScale, y: yScale))
        pictureLayer.fillColor = UIColor.clear.cgColor
        pictureLayer.strokeColor = UIColor.blue.cgColor
        pictureLayer.frame = canvasRect
        pictureLayer.masksToBounds = true
        pictureLayer.path = picturePath.cgPath

    }
}
