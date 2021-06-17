import Foundation

struct HeartEvent {
    var endDiastoleVolume: Double = 0.0
    var endSistolVolume: Double = 0.0
    var diastolicPressure: Double = 0.0
    var sistolicPressure: Double = 0.0
    init(endDiastoleVolume: Double, endSistolVolume: Double, diastolicPressure: Double, sistolicPressure: Double) {
        self.endDiastoleVolume = endDiastoleVolume
        self.endSistolVolume = endSistolVolume
        self.diastolicPressure = diastolicPressure
        self.sistolicPressure = sistolicPressure
    }
}
class Heart {
    
    var clock: Clock
    var observer: [ GraphData ] = []
    var pacemaker: Pacemaker

    var leftAtrium: AtriumCavity
    var leftVentricle: VentricleCavity
    var aorta: Cavity
    var arteryCavity: Cavity
    var veinCavity: Cavity
    var mitralValve: UnidirectionalValve
    var sigmoidValve: UnidirectionalValve
    var arteryValve: BidirectionalValve
    var endCircuit: BidirectionalValve
    var beginCircuit: BidirectionalValve
    var cavities: [Cavity]
    var valves: [Valve]

    // var heartEvent : HeartEvent

    var onValveChangedListener : ((HeartEvent) -> ())? = nil
    var onHeartChangedListener: ((HeartEvent) -> ())? = nil

    func calculateAdvance(lapseOfTime: Int) throws {
        pacemaker.reCalculateFactor(refreshLapse: Double(lapseOfTime))
        for valve in valves { try! valve.calculateFlows(tempo: Double(lapseOfTime)) }
        for cavity in cavities {cavity.calculateVolumen() }

        //onHeartChangedListener?.invoke(heartEvent)
        observer.forEach {grapherData in
            grapherData.semaphore.wait()
            grapherData.updateValue()
            grapherData.semaphore.signal()
        }
    }

    init(clock: Clock){
        self.clock = clock
        pacemaker = Pacemaker(clock: clock, frecuency: 60)
        
        
        leftAtrium = AtriumCavity(pacemaker: pacemaker, volumen:30.0, slackVol:20.0, contrVol: 5.0, relax: 8.0, contr:200.0)
        leftVentricle = VentricleCavity(pacemaker:pacemaker, volumen:120.0, slackVol:80.0, contrVol:20.0, relax:10.0, contr:800.0)
        aorta = AortaCavity(pacemaker: pacemaker, volumen: 100.0)
        arteryCavity = ArteryCavity(pacemaker: pacemaker, volumen: 500.0)
        veinCavity = VeinCavity(pacemaker: pacemaker, volumen: 5000.0)
        mitralValve = UnidirectionalValve(resistance: 30.0, preCavity: leftAtrium, postCavity: leftVentricle)
        sigmoidValve = UnidirectionalValve(resistance: 40.0, preCavity: leftVentricle, postCavity: aorta)
        arteryValve = BidirectionalValve(resistance: 500.0, preCavity: aorta, postCavity: arteryCavity)
        endCircuit = BidirectionalValve(resistance: 500.0, preCavity: arteryCavity, postCavity: veinCavity)
        beginCircuit = BidirectionalValve(resistance: 50.0, preCavity: veinCavity, postCavity: leftAtrium)
        cavities = [leftAtrium, leftVentricle, aorta, arteryCavity, veinCavity]
        valves = [mitralValve, sigmoidValve, arteryValve, endCircuit, beginCircuit]

    }
}


