//
//  ViewController.swift
//  PolygonClipping
//
//  Created by Siradanai Sutin on 6/2/2564 BE.
//

import Cocoa
import SwiftUI

class ViewController: NSViewController {
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var xminLabel: NSTextField!
    @IBOutlet weak var yminLabel: NSTextField!
    @IBOutlet weak var xmaxLabel: NSTextField!
    @IBOutlet weak var ymaxLabel: NSTextField!
    @IBOutlet var polygonTextView: NSTextView!
    
    private var sampleInput = ["(9,10)", "(15,16)", "(21,10)", "(15,4)"].joined(separator: "->")
    private var clippingController = ClippingController()
    
    @IBOutlet var clippedLabel: NSTextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        xminLabel.stringValue = "10"
        yminLabel.stringValue = "5"
        xmaxLabel.stringValue = "20"
        ymaxLabel.stringValue = "15"
        polygonTextView.string = sampleInput
        
        
        render()
         
        graphView.delegate = self
        graphView.display()
    }
    
    private func render() {
        prepareSubjectPolygonToController()
        prepareClippingVerticeToController()
    }
    
    @IBAction func renderDiamond(_ sender: Any) {
        polygonTextView.string = "(12,16)->(18,16)->(21,12)->(15,4)->(9,12)"
        render()
        graphView.display()
    }
    
    @IBAction func renderStar(_ sender: Any) {
        polygonTextView.string = "(15,17)->(17,13)->(22,13)->(18,9)->(20,4)->(15,7)->(10,4)->(12,9)->(8,13)->(13,13)"
        render()
        graphView.display()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func prepareSubjectPolygonVertice() -> [NSPoint] {
        
        var points = [NSPoint]()
        let str = polygonTextView.string.replacingOccurrences(of: " ", with: "", options: .regularExpression, range: nil)
        let strArr = str.components(separatedBy: "->")
        
        strArr.forEach { (NSPointStr) in
            let pointString = NSPointStr.replacingOccurrences(of: "[(]|[)]", with: "",
                                                             options: .regularExpression,
                                                             range: nil).components(separatedBy: ",")
            
            
            guard pointString.count == 2 else { print("Error"); return }
            guard let x = Int(pointString[0]), let y = Int(pointString[1]) else {
                return
            }
            
            points.append(NSPoint(x: x, y: y))
        }
        return points
    }
    
    
    func convertWindowPointsLabel() -> (xmin: Int, ymin: Int, xmax: Int, ymax: Int) {
        guard let _xmin = Int(xminLabel.stringValue),
              let _ymin = Int(yminLabel.stringValue),
              let _xmax = Int(xmaxLabel.stringValue),
              let _ymax = Int(ymaxLabel.stringValue) else {
            print("Cant extract")
            return (xmin: 0, ymin: 0, xmax: 0, ymax: 0)
        }
        return (xmin: _xmin, ymin: _ymin, xmax: _xmax, ymax: _ymax)
        
    }
    
    func prepareClippingVerticeToController() {
        let windowPoints = convertWindowPointsLabel()
        clippingController.clipPolygon.updatePoints(xmin: windowPoints.xmin,
                                               xmax: windowPoints.xmax,
                                               ymin: windowPoints.ymin,
                                               ymax: windowPoints.ymax)
    }
    
    func prepareSubjectPolygonToController() {
        let points = prepareSubjectPolygonVertice()
        clippingController.polygon.points = points
    }
    
}


extension ViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) { // NSTextField -> Window (Clip) Update
        prepareClippingVerticeToController()
        graphView.display()
    }
}

extension ViewController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) { // NSTextView -> Subject Polygon
        prepareSubjectPolygonToController()
        graphView.display()
    }
}

extension ViewController: GrapViewDelegate {
    
    
    func getClippedPolygon() -> [NSPoint] {
        let clippedPolygon = clippingController.performClipping()
        clippedLabel.string = clippedPolygon.getPrettyResultFormat()
        return clippedPolygon.points
    }
    
    
    
    func graphViewGetClipPolygonVertice() -> [NSPoint] { // Window
        return clippingController.clipPolygon.getPoints()
    }
    

    
    func getSubjectPolygonVertice() -> [NSPoint] {
        print("Subject Polygon Vertice \(clippingController.polygon.points)")
        return clippingController.polygon.points
        
    }
    
}
