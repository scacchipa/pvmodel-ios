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
    var clock: Clock
    var heart: Heart
    
    let loopData: LoopPVGrapherData
    let volumenData: VolumenEnTiempoGrapherData
    let pressureData: PresionEnTiempoGrapherData
    let contractilityData: TensionGrapherData
    
    var grapherVC: GrapherViewController?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var velSlider: VerticalSlider!
    @IBOutlet weak var preloadSlider: HorizontalSlider!
    @IBOutlet weak var afterloadSlider: HorizontalSlider!
    @IBOutlet weak var contractSlider: HorizontalSlider!
    
    var timerThread: Timer? = nil
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        clock = Clock()
        heart = Heart(clock: clock)
        
        loopData = LoopPVGrapherData(source: heart)
        volumenData = VolumenEnTiempoGrapherData(source: heart)
        pressureData = PresionEnTiempoGrapherData(source: heart)
        contractilityData = TensionGrapherData(source: heart)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        clock = Clock()
        heart = Heart(clock: clock)
        
        loopData = LoopPVGrapherData(source: heart)
        volumenData = VolumenEnTiempoGrapherData(source: heart)
        pressureData = PresionEnTiempoGrapherData(source: heart)
        contractilityData = TensionGrapherData(source: heart)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        grapherVC = GrapherViewController(grapherData: loopData)
        addChild(grapherVC!)
        
        grapherVC!.view.frame = containerView.frame
        view.addSubview(grapherVC!.view)
        grapherVC?.didMove(toParent: self)
        
        velSlider.addTarget(self, action: #selector(velocityChanged), for: UIControl.Event.valueChanged)
        preloadSlider.addTarget(self, action: #selector(preloadChanged), for: UIControl.Event.valueChanged)
        afterloadSlider.addTarget(self, action: #selector(afterloadChanged), for: UIControl.Event.valueChanged)
        contractSlider.addTarget(self, action: #selector(contractilityChanged), for: UIControl.Event.valueChanged)
        timerThread = Timer.scheduledTimer(timeInterval: TimeInterval(lapseOfTime / 1000), target: self, selector: #selector(mainRefresh), userInfo: nil,  repeats: true)
    }
    @objc func mainRefresh(timer: Timer) {
        try? heart.calculateAdvance(lapseOfTime: lapseOfTime)
        clock.advance(lapse: lapseOfTime)
        
        loopData.updateValue()
        volumenData.updateValue()
        pressureData.updateValue()
        contractilityData.updateValue()
        
        DispatchQueue.main.async { [weak self] in
            if ((self?.grapherVC?.isViewLoaded) != nil) {
                self?.grapherVC?.view?.setNeedsDisplay()
            }
        }
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

