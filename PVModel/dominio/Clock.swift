import Foundation

class Clock {
    public var time:Int = 0
    
    init(initialTime: Int) {
        self.time = initialTime
    }
    init() {
        self.time = 0
    }
    func advance(lapse:Int) {
        self.time += lapse
    }
}

