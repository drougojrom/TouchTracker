//
//  DrawView.swift
//  TouchTracker
//
//  Created by Roman Ustiantcev on 26/03/16.
//  Copyright © 2016 Roman Ustiantcev. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var currentLine: Line?
    var finishedLines = [Line]()
    
    func strokeLine(line: Line){
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = CGLineCap.Round
        
        path.moveToPoint(line.begin)
        path.addLineToPoint(line.end)
        
        path.stroke()
    }
    
    override func drawRect(rect: CGRect) {
        // draw finished line in black
        UIColor.blackColor().setStroke()
        
        for line in finishedLines {
            strokeLine(line)
        }
        if let line = currentLine {
            // if there is a line being drawn, do it in red
            UIColor.redColor().setStroke()
            strokeLine(line)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        
        // get location of touch
        let location = touch.locationInView(self)
        currentLine = Line(begin: location, end: location)
        
        setNeedsDisplay()
    }
    
}
