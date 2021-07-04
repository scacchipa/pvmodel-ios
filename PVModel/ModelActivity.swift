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
    var buttonArray: [UIButton] = []
    
    @IBOutlet weak var pvButton: UIButton!
    @IBOutlet weak var vtButton: UIButton!
    @IBOutlet weak var ptButton: UIButton!
    @IBOutlet weak var contrButton: UIButton!
    
    @IBAction func buttonTouchUpInside(_ sender: UIButton) {
        toSelectOnlyAButton(sender)
        switch sender {
        case pvButton:
            grapherVC?.changeGrapherData(loopData)
            break
        case vtButton:
            grapherVC?.changeGrapherData(volumenData)
            break
        case ptButton:
            grapherVC?.changeGrapherData(pressureData)
            break
        case contrButton:
            grapherVC?.changeGrapherData(contractilityData)
            break
        default: break
            
        }
    }

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
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonArray = [pvButton, vtButton, ptButton, contrButton]
        
        forAllButtons(
            selectedButton: pvButton,
            trueScript: { button in button.isSelected = true },
            falseScript: { button in button.isSelected = false })
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
        timerThread = Timer.scheduledTimer(timeInterval: TimeInterval(Double(lapseOfTime) / 1000), target: self, selector: #selector(mainRefresh), userInfo: nil,  repeats: true)
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
    private func forAllButtons(selectedButton: UIButton, trueScript: (UIButton)->(), falseScript: (UIButton)->()) {
        for idx in 0..<buttonArray.count {
            let button = buttonArray[idx]
            if (button == selectedButton) {
                trueScript(button)
            } else {
                falseScript(button)
            }
        }
    }
    private func toSelectOnlyAButton(_ selButton: UIButton) {
        if !selButton.isSelected {
            forAllButtons(
                selectedButton: selButton,
                trueScript: { button in button.isSelected = true },
                falseScript: { button in button.isSelected = false})
        }
    }

    @objc func velocityChanged(control: VerticalSlider, withEvent event: UIEvent) {
        timerThread!.invalidate()
        timerThread = Timer.scheduledTimer(timeInterval: TimeInterval(Double(lapseOfTime) / 1000.0 * 100.0 / Double(control.value)), target: self, selector: #selector(mainRefresh), userInfo: nil,  repeats: true)
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

