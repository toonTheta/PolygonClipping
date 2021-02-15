//
//  NSPoint_Extension_.swift
//  PolygonClipping
//
//  Created by Siradanai Sutin on 13/2/2564 BE.
//

import Foundation
import Cocoa

public typealias CohenBit = (bit1: Int, bit2: Int, bit3: Int, bit4: Int)
extension NSPoint {
    
    public func getCohenBitRepresent(on window: Window) -> CohenBit {
        var cohenBit: CohenBit
        
        cohenBit.bit1 = ((Int(self.y) - window.ymax) > 0) ? 1: 0
        cohenBit.bit2 = ((window.ymin - Int(self.y)) > 0) ? 1: 0
        cohenBit.bit3 = ((Int(self.x) - window.xmax) > 0) ? 1: 0
        cohenBit.bit4 = ((window.xmin - Int(self.x)) > 0) ? 1: 0
        
        return cohenBit
    }
}
