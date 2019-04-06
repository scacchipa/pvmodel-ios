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
    public var clock:Clock = Clock()
    @IBOutlet weak var imageRenderView: ImageRenderView!
    override func viewDidAppear(_ animated: Bool) {

        imageRenderView.createSubLayers()

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
    
//    private var framePath: UIBezierPath!
//    private var picturePath: UIBezierPath!
    
    private var pictureLayer: CALayer!
    private var frameLayer:CALayer!
    private var absLabelLayer:CALayer!
    private var ordLabelLayer:CALayer!
    
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
    func createPictureLayer() -> CALayer! {
        let picturePath = UIBezierPath()
        picturePath.addArc(withCenter: CGPoint(x: 0, y: 0), radius: CGFloat(40), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.strokeColor = UIColor.blue.cgColor
        layer.frame = canvasRect
        layer.masksToBounds = true
        layer.path = picturePath.cgPath
        
        return layer
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
}
