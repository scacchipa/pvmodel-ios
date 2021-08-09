//
//  UserInterface.swift
//  PVModel
//
//  Created by Pablo Antonio Scacchi Bernasconi on 02/05/2019.
//  Copyright © 2019 Pablo Antonio Scacchi Bernasconi. All rights reserved.
//

// Source of class
// http://swiftnotions.com/2017/07/25/the-curious-case-of-the-vertical-slider/


import Foundation
import UIKit

@IBDesignable
class VerticalSlider :UIControl {
    @IBInspectable public var minValue:CGFloat = 1
    @IBInspectable public var minColor:UIColor = .purple
    
    @IBInspectable public var maxValue: CGFloat = 100.0
    @IBInspectable public var maxColor: UIColor = .lightGray
    
    @IBInspectable public var thumbRadius: CGFloat = 30.0
    @IBInspectable public var thumbCorner: CGFloat = 10.0
    @IBInspectable public var thumbColor: UIColor = .purple
    
    @IBInspectable public var trackWidth: CGFloat = 5.0
    
    @IBInspectable public var value: CGFloat = 100 {
        didSet {
            if value > maxValue {
                value = maxValue
            }
            if value < minValue {
                value = minValue
            }
            updateThumbRect()
        }
    }
    
    func trackLength() -> CGFloat {
        return self.bounds.height - (self.thumbOffset * 2)
    }
    lazy var thumbOffset: CGFloat = {
        return self.thumbRadius
    }()
    var thumbRect: CGRect!
    var isMoving = false
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        contentMode = .redraw
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true;
        contentMode = .redraw
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        updateThumbRect()
    }
    class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateThumbRect()
    }
    
    override func draw(_ rect: CGRect) {
        updateThumbRect()
        let context = UIGraphicsGetCurrentContext()
        
        //draw the max track
        let x = bounds.width / 2 - trackWidth / 2
        let maxTrackRect = CGRect(x: x, y: thumbOffset, width: trackWidth, height: yFromValue(value) - thumbOffset)
        let maxTrack = UIBezierPath(roundedRect: maxTrackRect, cornerRadius: 6)
        maxColor.setFill()
        maxTrack.fill()
        
        //draw the min track
        let minTrackRect = CGRect(x: x, y: yFromValue(value), width: trackWidth, height: bounds.height - yFromValue(value) - thumbOffset)
        let minTrack = UIBezierPath(roundedRect: minTrackRect, cornerRadius: 6)
        minColor.setFill()
        minTrack.fill()
        
        //draw the thumb
        let thumbFrame = CGRect(origin: thumbRect.origin, size: thumbRect.size)
        let thumb = UIBezierPath(roundedRect: thumbFrame, cornerRadius: thumbCorner)
        thumbColor.setFill()
        thumb.fill()
        
        context?.saveGState()
        context?.restoreGState()
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        if thumbRect.contains(touch.location(in: self)) {
            isMoving = true
        }
        return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let location = touch.location(in: self)
        if isMoving {
            let value = valueFromY(location.y)
            
            if value != minValue && value <= maxValue {
                self.value = value
                setNeedsDisplay()
            }
        }
        self.sendActions(for: UIControl.Event.valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        isMoving = false;
    }
    
    func valueFromY(_ y: CGFloat) -> CGFloat {
        let yOffset = bounds.height - thumbOffset - y
        return (yOffset * maxValue) / trackLength()
    }
    func yFromValue(_ value: CGFloat) -> CGFloat {
        let y = (value * trackLength()) / maxValue
        return bounds.height - thumbOffset - y
    }
    func updateThumbRect() {
        thumbRect = CGRect(origin: CGPoint(x: bounds.width / 2.5 - thumbRadius, y: yFromValue(value) - thumbRadius), size: CGSize(width: thumbRadius * 3.1, height: thumbRadius * 3.1))
    }
}
@IBDesignable
class HorizontalSlider: UIControl {
    @IBInspectable public var minValue:CGFloat = 1
    @IBInspectable public var minColor:UIColor = .purple
    
    @IBInspectable public var maxValue: CGFloat = 100.0
    @IBInspectable public var maxColor: UIColor = .lightGray
    
    @IBInspectable public var thumbRadius: CGFloat = 30.0
    @IBInspectable public var thumbCorner: CGFloat = 10.0
    @IBInspectable public var thumbColor: UIColor = .purple
    
    @IBInspectable public var trackWidth: CGFloat = 1.0
    
    @IBInspectable public var value: CGFloat = 100 {
        didSet {
            if value > maxValue {
                value = maxValue
            }
            if value < minValue {
                value = minValue
            }
            updateThumbRect()
        }
    }
    
    func trackLength() -> CGFloat {
        return self.bounds.width - (self.thumbOffset * 2)
    }
    lazy var thumbOffset: CGFloat = {
        return self.thumbRadius
    }()
    var thumbRect: CGRect!
    var isMoving = false
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        contentMode = .redraw
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.isUserInteractionEnabled = true;
        contentMode = .redraw
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        updateThumbRect()
    }
    class override var requiresConstraintBasedLayout: Bool {
        return true
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateThumbRect()
    }
    
    override func draw(_ rect: CGRect) {
        updateThumbRect()
        let context = UIGraphicsGetCurrentContext()
        
        //draw the max track
        let y = bounds.height / 2 - trackWidth / 2
        let maxTrackRect = CGRect(x: xFromValue(value), y: y, width: bounds.width - xFromValue(value) - thumbOffset, height: trackWidth)
        let maxTrack = UIBezierPath(roundedRect: maxTrackRect, cornerRadius: 6)
        
        maxColor.setFill()
        maxTrack.fill()
        
        //draw the min track

        let minTrackRect = CGRect(x: thumbOffset, y: y, width: xFromValue(value), height: trackWidth)
        let minTrack = UIBezierPath(roundedRect: minTrackRect, cornerRadius: 6)
        minColor.setFill()
        minTrack.fill()
        
        //draw the thumb
        let thumbFrame = CGRect(origin: thumbRect.origin, size: thumbRect.size)
        let thumb = UIBezierPath(roundedRect: thumbFrame, cornerRadius: thumbCorner)
        thumbColor.setFill()
        thumb.fill()
        
        context?.saveGState()
        context?.restoreGState()
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        if thumbRect.contains(touch.location(in: self)) {
            isMoving = true
        }
        return true
    }
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        
        let location = touch.location(in: self)
        if isMoving {
            let value = valueFromX(location.x)
            
            if value != minValue && value <= maxValue {
                self.value = value
                setNeedsDisplay()
            }
        }
        self.sendActions(for: UIControl.Event.valueChanged)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        isMoving = false;
    }
    
    func updateThumbRect() {
        thumbRect = CGRect(
                        origin: CGPoint(x: xFromValue(value) - thumbRadius, y: bounds.height / 3 - thumbRadius),
                        size: CGSize(width: thumbRadius * 3.1, height: thumbRadius * 3.1)
                    )
    }
    
    func valueFromX(_ x: CGFloat) -> CGFloat {
        //return ((x - thumbOffset) * maxValue) / trackLength()
        return (x - thumbOffset) / trackLength() * (maxValue - minValue) + minValue
    }
    
    func xFromValue(_ value: CGFloat) -> CGFloat {
        // return (value * trackLength()) / maxValue + thumbOffset
        return (value - minValue) / (maxValue - minValue) * trackLength() + thumbOffset
    }
    
}
