//
//  Window.swift
//  PolygonClipping
//
//  Created by Siradanai Sutin on 12/2/2564 BE.
//

import Foundation
import Cocoa

public enum Direction {
    case cw
    case ccw
}




public class Window {
    
    public var xmin: Int
    public var ymin: Int
    public var xmax: Int
    public var ymax: Int
    
    public var bottomLeft: NSPoint
    public var bottomRight: NSPoint
    public var topRight: NSPoint
    public var topLeft: NSPoint
    
    internal init(xmin: Int, xmax: Int, ymin: Int, ymax: Int) {
        
        self.xmin = xmin
        self.ymin = ymin
        self.xmax = xmax
        self.ymax = ymax
        
        self.bottomLeft = NSPoint(x: xmin, y: ymin)
        self.bottomRight = NSPoint(x: xmax, y: ymin)
        self.topRight = NSPoint(x: xmax, y: ymax)
        self.topLeft = NSPoint(x: xmin, y: ymax)
        
    }
    
    
    /// Return array of window's corner
    /// - Returns: array of NSPoint  counter clock wise directon
    public func getPoints() -> [NSPoint] {
        return [bottomLeft, bottomRight, topRight, topLeft]
    }
    
    public func updatePoints(xmin: Int, xmax: Int, ymin: Int, ymax: Int) {
        
        self.xmin = xmin
        self.ymin = ymin
        self.xmax = xmax
        self.ymax = ymax
        
        self.bottomLeft = NSPoint(x: xmin, y: ymin)
        self.bottomRight = NSPoint(x: xmax, y: ymin)
        self.topRight = NSPoint(x: xmax, y: ymax)
        self.topLeft = NSPoint(x: xmin, y: ymax)
    }
    
    
    public func doesContainPoint(_ point: NSPoint) -> Bool {
        return (Int(point.x) <= self.xmax && Int(point.x) >= self.xmin) &&
            ((Int(point.y) <= self.ymax && Int(point.y) >= self.ymin))
    }
    

    
    private func isOutOfBound(point: NSPoint) -> Bool {
        return point.x > CGFloat(xmax) ||
            point.x < CGFloat(xmin) ||
            point.y > CGFloat(ymax) ||
            point.y < CGFloat(ymin)
        
    }
    
    private func midPointSlicing(fixPoint: NSPoint, movingPoint: NSPoint) -> NSPoint {
        var point = NSPoint()
        point.x = (fixPoint.x + movingPoint.x)/2
        point.y = (fixPoint.y + movingPoint.y)/2
        return point
    }
    
    private func snapToBound(point: NSPoint) -> NSPoint {
        var point = NSPoint()
        point.x = point.x.rounded()
        point.y = point.y.rounded()
        
        if point.x > CGFloat(xmax) {
            point.x = CGFloat(xmax)
        } else if point.x < CGFloat(xmin) {
            point.x = CGFloat(xmin)
        }
        
        if point.y > CGFloat(ymax) {
            point.y = CGFloat(ymax)
        } else if point.y < CGFloat(ymin) {
            point.y = CGFloat(ymin)
        }
        
        return point
    }
    
    private func findAVisiblePoint(fixPoint: NSPoint, movingPoint: NSPoint) -> NSPoint {
        
        var currentPoint = movingPoint
        var fixPoint = fixPoint
        
        if !doesContainPoint(fixPoint) {
            while(true){
                
                currentPoint = midPointSlicing(fixPoint: fixPoint, movingPoint: currentPoint)
                var nextPoint = NSPoint()
                nextPoint = midPointSlicing(fixPoint: fixPoint, movingPoint: currentPoint)
                
                if isOutOfBound(point: currentPoint) {
                    fixPoint = nextPoint
                    currentPoint = midPointSlicing(fixPoint: fixPoint, movingPoint: currentPoint)
                    currentPoint.x = currentPoint.x.rounded()
                    currentPoint.y = currentPoint.y.rounded()
                    return currentPoint
                }
            }
        } else { return fixPoint }
    }
    
    public func getIntersectionPoints(endPointOne: NSPoint, endPointTwo: NSPoint) -> (endPointOne: NSPoint, endPointTwo: NSPoint) {
        
        var visiblePoints: (endPointOne: NSPoint, endPointTwo: NSPoint)
        
        // MARK: Fix Endpoint One
        visiblePoints.endPointOne = findAVisiblePoint(fixPoint: endPointOne, movingPoint: endPointTwo)
    
        // MARK: Fix Endpoint Two
        visiblePoints.endPointTwo = findAVisiblePoint(fixPoint: endPointTwo, movingPoint: endPointOne)
        
        return visiblePoints
    }
    
}
