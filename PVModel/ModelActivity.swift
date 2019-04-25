//
//  ModelActivity.swift
//  PVModel
//
//  Created by Pablo Antonio Scacchi Bernasconi on 23/03/2019.
//  Copyright © 2019 Pablo Antonio Scacchi Bernasconi. All rights reserved.
//

import Foundation

import UIKit

class ModelViewController : UIViewController {
    var clock:Clock
    var pacemaker:Pacemaker
    var leftAtrium: AtriumCavity
    var leftVentricle: VentricleCavity
    var aorta:AortaCavity
    var arteryCavity:ArteryCavity
    var veinCavity: VeinCavity
    
    var mitralValve:Valve
    var sigmoidValve:Valve
    var arteryValve:Valve
    var endCircuit:Valve
    var beginCircuit:Valve
    
    var cavities:[Cavity]
    var valves:[Valve]
    
    var counter = 0;
    
    @IBOutlet weak var imageRenderView: ImageRenderView!
    
    var timerThread: Timer? = nil
    var semaphore: DispatchSemaphore? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        clock = Clock()
        pacemaker = Pacemaker(modelController:nil, frecuency: 60)
        leftAtrium = AtriumCavity(pacemaker:pacemaker, volumen: 30, slackVol: 20, contrVol: 5, relax: 8, contr: 200)
        leftVentricle = VentricleCavity(pacemaker: pacemaker, volumen: 120, slackVol: 80, contrVol: 20, relax: 10, contr: 800)
        aorta = AortaCavity(pacemaker:pacemaker, volumen:100)
        arteryCavity = ArteryCavity(pacemaker:pacemaker, volumen:500)
        veinCavity = VeinCavity(pacemaker:pacemaker, volumen:5000)
        
        mitralValve = UnidirectionalValve(resistance:30, preCavity: leftAtrium, postCavity: leftVentricle)
        
        sigmoidValve = UnidirectionalValve(resistance: 40,  preCavity: leftVentricle, postCavity: aorta);
        arteryValve = BidirectionalValve(resistance: 500, preCavity: aorta, postCavity: arteryCavity);
        endCircuit = BidirectionalValve(resistance: 500, preCavity: arteryCavity, postCavity: veinCavity);
        beginCircuit = UnidirectionalValve(resistance: 50, preCavity: veinCavity, postCavity: leftAtrium);
        
        cavities = [leftAtrium, leftVentricle, aorta, arteryCavity, veinCavity];
        valves = [mitralValve, sigmoidValve, arteryValve, endCircuit, beginCircuit];
        
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        
        pacemaker.modelController = self;
        semaphore = DispatchSemaphore(value: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        clock = Clock()
        pacemaker = Pacemaker(modelController:nil, frecuency: 60)
        leftAtrium = AtriumCavity(pacemaker:pacemaker, volumen: 30, slackVol: 20, contrVol: 5, relax: 8, contr: 200)
        leftVentricle = VentricleCavity(pacemaker: pacemaker, volumen: 120, slackVol: 80, contrVol: 20, relax: 10, contr: 800)
        aorta = AortaCavity(pacemaker:pacemaker, volumen:100)
        arteryCavity = ArteryCavity(pacemaker:pacemaker, volumen:500)
        veinCavity = VeinCavity(pacemaker:pacemaker, volumen:5000)
        
        mitralValve = UnidirectionalValve(resistance:30, preCavity: leftAtrium, postCavity: leftVentricle)
        
        sigmoidValve = UnidirectionalValve(resistance: 40,  preCavity: leftVentricle, postCavity: aorta);
        arteryValve = BidirectionalValve(resistance: 500, preCavity: aorta, postCavity: arteryCavity);
        endCircuit = BidirectionalValve(resistance: 500, preCavity: arteryCavity, postCavity: veinCavity);
        beginCircuit = UnidirectionalValve(resistance: 50, preCavity: veinCavity, postCavity: leftAtrium);
        
        cavities = [leftAtrium, leftVentricle, aorta, arteryCavity, veinCavity];
        valves = [mitralValve, sigmoidValve, arteryValve, endCircuit, beginCircuit];
        
        super.init(coder: aDecoder)
        
        pacemaker.modelController = self;
        semaphore = DispatchSemaphore(value: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imageRenderView.setCavity(cavity:leftVentricle)
        imageRenderView.createSubLayers()
        imageRenderView.setParent(parent:self)
        imageRenderView.setNeedsDisplay()

        timerThread = Timer.scheduledTimer(withTimeInterval: 0.002, repeats: true,  block: {timer in
            
            let lapseOfTime = 2.0;
            self.pacemaker.reCalculateFactor(refreshLapse: lapseOfTime)
            
            for valve in self.valves {
                do {
                    try valve.calculateFlows(tempo: lapseOfTime)
                } catch is Error {
                    print("Error al calcular flujos")
                }
            }
            for cavity in self.cavities {
                cavity.calculateVolumen()
            }
            self.semaphore!.wait()
            self.imageRenderView.updateValue()
            self.semaphore!.signal()
            
            self.counter += 1
            if (self.counter == 1) {
                self.imageRenderView.setNeedsDisplay()
                self.counter = 0
            }
            self.clock.advance(lapse: Int(lapseOfTime))

            
            
        } )
    }
}

class ImageRenderView: UIView   {

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
