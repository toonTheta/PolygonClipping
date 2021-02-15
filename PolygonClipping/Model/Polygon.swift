//
//  Polygon.swift
//  PolygonClipping
//
//  Created by Siradanai Sutin on 13/2/2564 BE.
//

import Foundation

public class Polygon {
        
    public var points: [NSPoint]
    
    internal init(points: [NSPoint]) {
        self.points = points
    }
    
    func getPrettyResultFormat() -> String {
        var result = [String]()
        for point in points {
            let xStr = String(format: "%.2f", point.x)
            let yStr = String(format: "%.2f", point.y)
            result.append("(\(xStr), \(yStr))")
        }
        return result.joined(separator: "\n")
    }
}
