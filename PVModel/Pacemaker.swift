//
//  Pacemaker.swift
//  PVModel
//
//  Created by Pablo Antonio Scacchi Bernasconi on 22/03/2019.
//  Copyright © 2019 Pablo Antonio Scacchi Bernasconi. All rights reserved.
//

import Foundation


class Pacemaker {
    
    var modelController:ModelViewController
    var frecuency: Double;
    var lastCycle: Int = 0
    var auricularContractilityFactor:Double = 0.0
    var ventrContractilityFactor = 0.0
    var period: Int = 0
    var delayMaxContr:Double = 200
    var delayMinContr:Double = 50
    init(modelController:ModelViewController, frecuency: Double) {
        self.modelController = modelController
        self.frecuency = frecuency
        self.auricularContractilityFactor = 0.0
        self.ventrContractilityFactor = 0.0
        self.lastCycle = modelController.clock.time
        self.period = 60000 / Int(self.frecuency)
    }
    
    func reCalculateFactor(refreshLapse: Double) {
        let sistoleAuricularOnset = 300 / 800 * period
        let diastoleAuricularOffSet = 450 / 800 * period
        let sistoleVentricularOnset = 500 / 800 * period
        
        if (self.lastCycle + period < modelController.clock.time) {
            self.lastCycle = modelController.clock.time
        }
        
        let lapse = (modelController.clock.time - self.lastCycle)
        
        let auricTrend: Double
        let ventrTrend: Double
        if (lapse < sistoleAuricularOnset) {
            auricTrend = 0.0
            ventrTrend = 0.0
        } else if (lapse < diastoleAuricularOffSet) {
            auricTrend = 1.0
            ventrTrend = 0.0
        } else if (lapse < sistoleVentricularOnset) {
            auricTrend = 0.0
            ventrTrend = 0.0
        } else {
            auricTrend = 0.0
            ventrTrend = 1.0
        }
        
        var shockVentr: Double
        if (ventrContractilityFactor < ventrTrend) {
            shockVentr = min(ventrContractilityFactor + 1 / delayMaxContr * refreshLapse, ventrTrend)
        } else {
            shockVentr = max(ventrContractilityFactor - 1 / delayMinContr * refreshLapse, ventrTrend)
        }
        
        ventrContractilityFactor = (ventrContractilityFactor + shockVentr) / 2 // buffer
        
        var shockAtrium: Double
        if (auricularContractilityFactor < auricTrend) {
            shockAtrium = min(auricularContractilityFactor + 1 / delayMaxContr * refreshLapse, auricTrend)
        } else {
            shockAtrium = max(auricularContractilityFactor - 1 / delayMinContr * refreshLapse, auricTrend)
        }
        
        auricularContractilityFactor = (auricularContractilityFactor + shockAtrium) / 2 // buffer
        
    }
}
