//
//  Clock.swift
//  PVModel
//
//  Created by Pablo Antonio Scacchi Bernasconi on 24/03/2019.
//  Copyright © 2019 Pablo Antonio Scacchi Bernasconi. All rights reserved.
//

import Foundation

class Clock {
    public var time:Int = 0;
    
    func advance(lapse:Int) {
        self.time += lapse
    }
}

