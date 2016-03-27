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
        addGestureRecognizer(doubleTapRecognizer)
        
    }
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer){
        print("Recognized a double tap")
        
        currentLines.removeAll(keepCapacity: false)
        finishedLines.removeAll(keepCapacity: false)
        
        setNeedsDisplay()
        
    }
    
}
