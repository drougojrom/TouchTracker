//
//  DrawView.swift
//  TouchTracker
//
//  Created by Roman Ustiantcev on 26/03/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    @IBInspectable var finishedLineColor = UIColor.blackColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var currentLineColor = UIColor.redColor() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var currentLines = [NSValue:Line]()
    var finishedLines = [Line]()
    var selectedLineIndex: Int?
    
    func strokeLine(line: Line){
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.Round
        
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        path.stroke()
    }
    
    override func drawRect(rect: CGRect) {
        // draw finished line in black
        finishedLineColor.setStroke()
        
        
        
        for line in finishedLines {
            // get angle between two points
            let deltaX = line.end.x - line.begin.x
            let deltaY = line.end.y - line.begin.y
            
            // angle
            let angleInDegrees = atan2(deltaX, deltaY) * 180 / CGFloat(M_PI)
            let color = UIColor(white: angleInDegrees / 360, alpha: 0.5)
            color.setStroke()
            
            strokeLine(line)
        }
        
        // draw current lines in red
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            strokeLine(line)
        }
        
        if let index = selectedLineIndex {
            UIColor.greenColor().setStroke()
            let selectedLine = finishedLines[index]
            strokeLine(selectedLine)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // put in a log statement to see other events
        print(#function)
        
        for touch in touches {
            let location = touch.locationInView(self)
            
            let newLine = Line(begin: location, end: location)
            let key = NSValue(nonretainedObject: touch)
            currentLines[key] = newLine
        }
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // put in a log statement to see other events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.locationInView(self)
        }
        setNeedsDisplay()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        // put in a log statement to see other events
        print(#function)
        
        for touch in touches {
            let key = NSValue(nonretainedObject: touch)
            if var line = currentLines[key]{
                line.end = touch.locationInView(self)
                finishedLines.append(line)
                currentLines.removeValueForKey(key)
            }
        }
        setNeedsDisplay()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        // put in a log statement to see other events
        print(#function)
        
        currentLines.removeAll()
        setNeedsDisplay()
    }
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "tap:")
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.requireGestureRecognizerToFail(doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer){
        print("Recognized a double tap")
        
        selectedLineIndex = nil
        
        currentLines.removeAll(keepCapacity: false)
        finishedLines.removeAll(keepCapacity: false)
        
        setNeedsDisplay()
        
    }
    
    func tap(gestureRecognizer: UIGestureRecognizer){
        print("Recognized a tap")
        
        let point = gestureRecognizer.locationInView(self)
        selectedLineIndex = indexOfLineAtPoint(point)
        
        setNeedsDisplay()
    }
    
    // method returns the index of line
    func indexOfLineAtPoint(point: CGPoint) -> Int? {
        for (index, line) in finishedLines.enumerate() {
            let begin = line.begin
            let end = line.end
            
            // check a few points of line
            for t in CGFloat(0).stride(to: 1.0, by: 0.05){
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // if the tapped point is within 20 points, lets return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        }
        
        // if nothing is close to tap, return nil
        return nil
    }
    
}
