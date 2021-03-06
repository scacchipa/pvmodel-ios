import Foundation

struct ValveEvent{
    let preCavityPressure: Double
    let preCavityVolume: Double
    let posCavityPressure: Double
    let posCavityVolume: Double
    let flow: Double
    init (preCavityPressure: Double, preCavityVolume: Double, posCavityPressure: Double, posCavityVolume: Double, flow: Double) {
        self.preCavityPressure = preCavityPressure
        self.preCavityVolume = preCavityVolume
        self.posCavityPressure = posCavityPressure
        self.posCavityVolume = posCavityVolume
        self.flow = flow
    }
}

class Valve {
    public var resistance: Double// (mmHg/mseg/ml)
    let preCavity: Cavity
    let postCavity: Cavity
    
    init(resistance:Double, preCavity: Cavity, postCavity: Cavity) {
        self.resistance = resistance
        self.preCavity = preCavity
        self.postCavity = postCavity
    }
    
    func isOpened() -> Bool {
        return preCavity.pressure > postCavity.pressure
    }
    func flow(tempo: Double) throws -> Double {
        
        // basado en la descarga de un capacitor
        //
        // flow = P0/R*e^(-t/(R*Co))
        // accumalateFlow = integrate flow;
        
        // float equilibriumPressure = this.equilibriumPressure();
        
        let difPressure = preCavity.pressure - postCavity.pressure
        let preComplance = preCavity.volumen / preCavity.pressure
        let postComplance = postCavity.volumen / postCavity.pressure
        
        var tau = (preComplance + postComplance) / (resistance * preComplance * postComplance) // trouble when pre/postComplance is Infinite (infinite over infinite)
        if tau.isNaN {
            if preComplance.isInfinite || postComplance.isInfinite {
                tau = 1.0 / resistance
            } else if preComplance.isInfinite {
                tau = postComplance / (resistance * postComplance)
            } else {
                tau = postComplance / (resistance * preComplance)
            }
        }
        
        let flow0 = difPressure / resistance
        let accumulateFlow = (flow0 - flow0 * exp(-tau * tempo)) / tau
        if (accumulateFlow.isNaN) {
            throw NSError(domain: "Error de calculo", code: -101, userInfo: nil)
        }
        return accumulateFlow
    }
    
    func calculateFlows(tempo: Double) throws {
        throw NSError(domain: "Funci??n abstracta. Debe ser definida", code: -100, userInfo: nil)
    }
    func equilibriumPressure() -> Double {
        let preComplance = preCavity.volumen / preCavity.pressure
        let postComplance = postCavity.volumen / postCavity.pressure
        
        // VT = preCavity.volumen + postCavity.volumen
        // VT = preCavity.pressure * preComplance + postCavity.pressure * postComplance
        
        // Si preCavity.pressure = postCavity.pressure = pressure
        // VT = pressure * preComplance + pressure * postComplance
        // preCavity.volumen + postCavity.volumen = pressure (preComplance + postComplance)
        // pressure = (preComplance + postComplance) / (preCavity.volumen + postCavity.volumen)
        return (preCavity.volumen + postCavity.volumen) / (preComplance + postComplance)
    }
}
class UnidirectionalValve: Valve {
    var previousValveState: Bool = false
    var onOpenValveListener: ((ValveEvent)->())? = nil
    var onCloseValveListener: ((ValveEvent)->())? = nil
    
    override init(resistance: Double, preCavity: Cavity, postCavity: Cavity){
        super.init(resistance: resistance, preCavity: preCavity, postCavity: postCavity)
    }
    
    override func calculateFlows(tempo: Double) throws {
        let accumulateFlow = try flow(tempo: tempo)
        if (accumulateFlow > 0) {
            preCavity.addFlow(flow: -accumulateFlow)
            postCavity.addFlow(flow: accumulateFlow)
        }
        let valveState = accumulateFlow > 0
        if (valveState != previousValveState) {
            self.onOpenValveListener?(ValveEvent(preCavityPressure: preCavity.pressure, preCavityVolume: preCavity.volumen, posCavityPressure: postCavity.pressure, posCavityVolume: postCavity.volumen, flow: accumulateFlow))
            previousValveState = valveState
        } else {
            self.onCloseValveListener?(ValveEvent(preCavityPressure: preCavity.pressure, preCavityVolume: preCavity.volumen, posCavityPressure: postCavity.pressure, posCavityVolume: postCavity.volumen, flow: accumulateFlow))
            previousValveState = valveState
        }
    }
}
class BidirectionalValve: Valve {
    override init(resistance: Double, preCavity: Cavity, postCavity: Cavity) {
        super.init(resistance:resistance, preCavity: preCavity, postCavity: postCavity)
    }
    
    override func calculateFlows(tempo: Double) throws { // in second
        let accumulateFlow = try flow(tempo:tempo)
        preCavity.addFlow(flow:-accumulateFlow)
        postCavity.addFlow(flow:accumulateFlow)
    }
}
