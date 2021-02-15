//
//  ClippingController.swift
//  PolygonClipping
//
//  Created by Siradanai Sutin on 12/2/2564 BE.
//

import Foundation

public enum PointStatus {
    case inside
    case outside
}

private enum Edge: Int {
    case left = 0
    case bottom = 1
    case right = 2
    case top = 3
}

private enum Axis {
    case vertical
    case horizontal
}

private enum PointError: Error {
    case parallelLine
}


public class ClippingController {
    
    public var clipPolygon: Window = Window(xmin: 0, xmax: 0, ymin: 0, ymax: 0)
    public var polygon: Polygon = Polygon(points: [])
    private var indexEdgeDict: [Int: Edge] = [0: .left, 1: .bottom, 2: .right, 3: .top]
    
    /// Find the intersection from two given points and the polygon edge either vertical or horizontal
    /// - Parameters:
    ///   - endpointOne: First endpoint
    ///   - endpointTwo: The other endpoint
    ///   - edge: Polygon Edge
    ///   - value: The value associate to the edge
    /// - Throws: If there the line is parallel to the edge
    /// - Returns: The intersection point
    private func solveTheIntersection(endpointOne: NSPoint, endpointTwo: NSPoint, edge: Edge, value: Int) throws -> NSPoint {
        
        if (edge == .top || edge == .bottom) && endpointOne.y == endpointTwo.y && endpointOne.y != CGFloat(value) {
            throw PointError.parallelLine
        }
        
        if (edge == .left || edge == .right) && endpointOne.x == endpointTwo.x && endpointOne.x != CGFloat(value) {
            throw PointError.parallelLine
        }
        
        guard endpointOne.x != endpointTwo.x else {
            return NSPoint(x: endpointOne.x, y: CGFloat(value))
        }
        
        let slope = (endpointOne.y - endpointTwo.y) / (endpointOne.x - endpointTwo.x)
        let c: CGFloat = endpointOne.y - (slope * endpointOne.x)
        
        switch edge {
        case .top, .bottom: return NSPoint(x: (CGFloat(value) - c)/slope , y: CGFloat(value))
        case .left, .right: return NSPoint(x: CGFloat(value), y: (slope * CGFloat(value)) + c )
        }
        
    }
    
    /// Get the window (clip polygon) edge value
    /// - Parameter edge: Edge e.g. left, bottom, right, top
    /// - Returns: the value of associated line
    private func getEdgeAssociatedValue(edge: Edge) -> Int {
        switch edge {
        case .left: return clipPolygon.xmin
        case .bottom: return clipPolygon.ymin
        case .right: return clipPolygon.xmax
        case .top: return clipPolygon.ymax
        }
    }
    
    
    /// Find the position of the specify point that is inside or outside the edge
    /// - Parameters:
    ///   - endpoint: the specify point
    ///   - edge: polygon's side
    /// - Returns: the position that is inside or outside
    private func getPointStatus(endpoint: NSPoint, edge: Edge) -> PointStatus {
        switch edge {
        case .left:
            return (endpoint.x < CGFloat(clipPolygon.xmin)) ? .outside : .inside
        case .bottom:
            return (endpoint.y < CGFloat(clipPolygon.ymin)) ? .outside : .inside
        case .right:
            return (endpoint.x > CGFloat(clipPolygon.xmax)) ? .outside : .inside
        case .top:
            return (endpoint.y > CGFloat(clipPolygon.ymax)) ? .outside : .inside
        }
    }
    
    /// Calculate new clipping result using Sutherland Algorithm
    /// - Parameters:
    ///   - edge: Polygon's Edge
    ///   - points: The original points for the iteration
    /// - Returns: New clipping points
    private func getNewClippingResult(edge: Edge, points: [NSPoint]) -> [NSPoint] {
        
        var result = [NSPoint]()
        
        for i in points.indices {
            let point = points[i]
            let nextPoint = (i == points.count - 1) ? points[0] : points[i+1]
            
            let status = getPointStatus(endpoint: point, edge: edge)
            let nextStatus = getPointStatus(endpoint: nextPoint, edge: edge)
            
            
            switch (status, nextStatus) {
            
            case (.outside, .outside):
                break
                
            case (.outside, .inside):
                let intersection = try! solveTheIntersection(endpointOne: point, endpointTwo: nextPoint, edge: edge, value: getEdgeAssociatedValue(edge: edge))
                result.append(intersection)
                result.append(nextPoint)
                
            case (.inside, .inside):
                result.append(nextPoint)
                
            case (.inside, .outside):
                let intersection = try! solveTheIntersection(endpointOne: point, endpointTwo: nextPoint, edge: edge, value: getEdgeAssociatedValue(edge: edge))
                result.append(intersection)
                
            }
            
        }
        return result
        
    }
    
    
    
    private func iterateAllEdges() -> [NSPoint] {
        
        let clippingPoints = polygon.points
        var iteratingResult = [NSPoint]()
        iteratingResult = clippingPoints
        
        for i in 0..<4 {
            let edge = indexEdgeDict[i]!
            iteratingResult = getNewClippingResult(edge: edge, points: iteratingResult)
            
        }
        
        return iteratingResult
        
    }
    
    /// Perform polygon clipping using Sutherland Algorithm
    public func performClipping() -> Polygon {
        
        print("Window: \(clipPolygon.getPoints())")
        let clippedPolygon = Polygon(points: [])
        clippedPolygon.points = iterateAllEdges()
        return clippedPolygon
    }
    
}
