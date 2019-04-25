//
//  Cavity.swift
//  PVModel
//
//  Created by Pablo Antonio Scacchi Bernasconi on 22/03/2019.
//  Copyright © 2019 Pablo Antonio Scacchi Bernasconi. All rights reserved.
//

import Foundation

class Cavity {
    var previousPressure:Double = 0
    var flows:Array<Double> = [Double]()
    var pacemaker: Pacemaker
    var volumen : Double
    init(pacemaker: Pacemaker, volumen: Double) {
        self.pacemaker = pacemaker
        self.volumen = volumen
    }
    var pressure:Double {
        get {
            return self.getIntrinsicPressure(volumen: self.volumen)
        }
    }
    func getIntrinsicPressure(volumen: Double) -> Double {
        fatalError("Subclasses need to implement the `sound()` method.")
    }
    func addFlow(flow:Double) {
        flows.append(flow);
    }
    func calculateVolumen() {
        previousPressure = pressure
        for flow in flows {
            volumen += flow
        }
        if volumen < 0.0 {
            volumen = 0.0
        }
        flows = []
    }
}

class AortaCavity: Cavity {
    override init(pacemaker: Pacemaker, volumen: Double) {
        super.init(pacemaker:pacemaker, volumen: volumen)
    }
    override func getIntrinsicPressure(volumen: Double) -> Double {
        return volumen * 1.5
    }
}
class ArteryCavity: Cavity {
    override init(pacemaker: Pacemaker, volumen: Double) {
        super.init(pacemaker:pacemaker, volumen:volumen)
    }
    override func getIntrinsicPressure(volumen: Double) -> Double {
        return volumen * 0.15
    }
}
class VeinCavity: Cavity {
    override init(pacemaker: Pacemaker, volumen: Double) {
        super.init(pacemaker:pacemaker, volumen:volumen)
    }
    override func getIntrinsicPressure(volumen: Double) -> Double {
        return volumen * 0.003
    }
}
class ContrCavity: Cavity {
    var slackRadious: Double
    var contrRadious: Double
    var contrElast: Double
    var relax: Double
    var contr: Double
    init(pacemaker: Pacemaker, volumen: Double, slackVol: Double, contrVol: Double, relax: Double, contr: Double) {
        self.slackRadious = pow(slackVol * 3.0 / (Double.pi * 4.0), 1.0 / 3.0)
        self.contrRadious = pow(contrVol * 3.0 / (Double.pi * 4.0), 1.0 / 3.0)
        self.contrElast = pow(contrVol / slackVol, 1.0 / 3.0)
        self.relax = relax
        self.contr = contr
        
        super.init(pacemaker:pacemaker, volumen:volumen)
    }
    override func getIntrinsicPressure(volumen: Double)-> Double {
        let contrFactor = contractilityFactor
        let Y = contrFactor * contr + relax
        let radious = pow(volumen * 3.0 / (Double.pi * 4.0), 1.0 / 3.0)
        return 2.0 * Y / radious * pow(0.5 * (pow(radious / slackRadious * pow(contrElast, -1.0), 2.0) - 1), 3.0)
    }
    var contractilityFactor:Double {
        get {
            fatalError("Subclasses need to implement the `sound()` method.")
        }
    }
}
class VentricleCavity: ContrCavity {
    override init (pacemaker: Pacemaker, volumen: Double, slackVol: Double, contrVol: Double, relax: Double, contr: Double) {
        super.init(pacemaker:pacemaker, volumen:volumen, slackVol:slackVol, contrVol:contrVol, relax:relax, contr: contr)
    }
    override var contractilityFactor:Double {
        get {
            return pacemaker.ventrContractilityFactor
        }
    }
}
class AtriumCavity: ContrCavity {
    override init(pacemaker: Pacemaker, volumen: Double, slackVol: Double, contrVol: Double, relax: Double, contr: Double) {
        super.init(pacemaker:pacemaker, volumen:volumen, slackVol:slackVol, contrVol:contrVol, relax:relax, contr: contr)
    }
    override var contractilityFactor:Double {
        get {
            return pacemaker.auricularContractilityFactor
        }
    }
}

