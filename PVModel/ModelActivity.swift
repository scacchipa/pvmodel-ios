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
    let lapseOfTime: Int = 10
    var clock = Clock(initialTime: 0)
    var heart: Heart
    
    @IBOutlet weak var imageRenderView: GrapherView!
    @IBOutlet weak var velSlider: VerticalSlider!
    @IBOutlet weak var preloadSlider: HorizontalSlider!
    @IBOutlet weak var afterloadSlider: HorizontalSlider!
    @IBOutlet weak var contractSlider: HorizontalSlider!
    
    var timerThread: Timer? = nil
    var semaphore: DispatchSemaphore? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        clock = Clock()
        heart = Heart(clock: self.clock)
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
        semaphore = DispatchSemaphore(value: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        clock = Clock()
        heart = Heart(clock: clock)
        super.init(coder: aDecoder)
        semaphore = DispatchSemaphore(value: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        imageRenderView.setCavity(cavity:leftVentricle)
        imageRenderView.createSubLayers()
        imageRenderView.setParent(parent:self)
        
        velSlider.addTarget(self, action: #selector(velocityChanged), for: UIControl.Event.valueChanged)
        preloadSlider.addTarget(self, action: #selector(preloadChanged), for: UIControl.Event.valueChanged)
        afterloadSlider.addTarget(self, action: #selector(afterloadChanged), for: UIControl.Event.valueChanged)
        contractSlider.addTarget(self, action: #selector(contractilityChanged), for: UIControl.Event.valueChanged)
        timerThread = Timer.scheduledTimer(timeInterval: TimeInterval(lapseOfTime / 1000), target: self, selector: #selector(mainRefresh), userInfo: nil,  repeats: true)
    }
    @objc func mainRefresh(timer: Timer) {
        try? heart.calculateAdvance(lapseOfTime: lapseOfTime)
        
        clock.advance(lapse: lapseOfTime)
        
        self.semaphore!.wait()
        self.imageRenderView.updateValue()
        self.semaphore!.signal()
        
        self.imageRenderView.setNeedsDisplay()
    }

    @objc func velocityChanged(control: VerticalSlider, withEvent event: UIEvent) {
        timerThread!.invalidate()
        timerThread = Timer.scheduledTimer(timeInterval: TimeInterval(Double(lapseOfTime) / Double(control.value) * 0.1), target: self, selector: #selector(mainRefresh), userInfo: nil,  repeats: true)
    }
    @objc func preloadChanged(control: HorizontalSlider, withEvent event: UIEvent) {
        heart.veinCavity.volumen = Double(control.value * 227);
    }
    @objc func afterloadChanged(control: HorizontalSlider, withEvent event: UIEvent) {
        heart.arteryValve.resistance = Double(control.value);
    }
    @objc func contractilityChanged(control: HorizontalSlider, with event: UIEvent) {
        heart.leftVentricle.contr = Double(control.value);
    }
}

