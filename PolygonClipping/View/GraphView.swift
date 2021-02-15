//
//  GraphView.swift
//  PolygonClipping
//
//  Created by Siradanai Sutin on 6/2/2564 BE.
//

import Cocoa


protocol GrapViewDelegate: class {
    func graphViewGetClipPolygonVertice() -> [NSPoint]
    func getSubjectPolygonVertice() -> [NSPoint]
    func getClippedPolygon() -> [NSPoint]
}

@IBDesignable
class GraphView: NSView {
    
    weak var delegate: GrapViewDelegate?
    @IBInspectable var pointSpacing: Int = 10
    @IBInspectable var gridLineColor: NSColor = NSColor.lightGray
    
    /// Main Function to draw a view
    /// - Parameter dirtyRect: View Frame
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let insetRect = NSRect(x: dirtyRect.minX ,
                               y: dirtyRect.minY ,
                               width: dirtyRect.width, height: dirtyRect.height )
        
        
        
        setupGridLayout(rect: insetRect)
        
        guard let _delegate = delegate else { return }
        drawPolygon(points: _delegate.graphViewGetClipPolygonVertice(), color: .red)
        if #available(OSX 10.13, *) {
            drawPolygon(points: _delegate.getSubjectPolygonVertice(),color: NSColor.init(named: "PolygonLine")!)
            drawPolygon(points: _delegate.getClippedPolygon(),color: NSColor.init(named: "ClippedLine")!)
        } else {
            drawPolygon(points: _delegate.getSubjectPolygonVertice(),color: .gray)
            drawPolygon(points: _delegate.getClippedPolygon(),color: .blue)
        }
        
        
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    
    func setupGridLayout(rect: NSRect) {
        
        drawVerticalLine(rect: rect)
        drawHorizontalLine(rect: rect)
        
        let path = NSBezierPath(rect: rect)
        NSColor.black.setStroke()
        path.lineWidth = 2
        path.stroke()
        
        
    }
    
    func drawVerticalLine(rect: NSRect) {
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            print("Error to get cg context")
            return
        }

        
        let slicings = Int((rect.width / 10).rounded())
        
        for i in 1..<slicings {
            
            let startingPoint = NSPoint(x: CGFloat(i) * CGFloat(pointSpacing), y: rect.minY)
            let endingPoint = NSPoint(x: CGFloat(i * pointSpacing), y: rect.maxY)
            
            context.move(to: startingPoint)
            context.addLine(to: endingPoint)
            context.setStrokeColor(gridLineColor.cgColor)
            i % 5 == 0 ? context.setLineWidth(2) : context.setLineWidth(1)
            context.strokePath()
            
        }
        
    }
    
    func drawHorizontalLine(rect: NSRect) {
        
        guard let context = NSGraphicsContext.current?.cgContext else {
            print("Error to get cg context")
            return
        }

        let slicings = Int((rect.height / 10).rounded())

        for i in 1..<slicings {
            let startingPoint = NSPoint(x: Int(rect.minX), y: Int(i * pointSpacing))
            let endingPoint = NSPoint(x: Int(rect.maxX), y: Int(i * pointSpacing))
            context.move(to: startingPoint)
            context.addLine(to: endingPoint)
            context.setStrokeColor(gridLineColor.cgColor)
            i % 5 == 0 ? context.setLineWidth(2) : context.setLineWidth(1)
            context.strokePath()
        }
        
    }
    
    func drawLine(lines: [(starting: NSPoint, ending:NSPoint)]) {
        let path = NSBezierPath()
        
        for line in lines {
            path.move(to: line.starting)
            path.line(to: line.ending)
            
            NSColor.red.setStroke()
            path.stroke()
        }
        
    }
    
    func drawPolygon(points: [NSPoint], color: NSColor) {
        
        guard !points.isEmpty else { return }
        let path = NSBezierPath()
        
        var resolutionizedPoint = NSPoint(x: CGFloat(points.first!.x * CGFloat(pointSpacing)), y: CGFloat(points.first!.y * CGFloat(pointSpacing)))
        path.move(to: resolutionizedPoint)
        for i in 1..<points.count {
            
            resolutionizedPoint = NSPoint(x: CGFloat(points[i].x * CGFloat(pointSpacing)),
                                          y: CGFloat(points[i].y * CGFloat(pointSpacing)))
            path.line(to: resolutionizedPoint)
            
        }
        path.close()
        color.setStroke()
        path.stroke()
    }
    
}
