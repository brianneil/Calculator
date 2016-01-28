//
//  CalculatorGraphViewController.swift
//  Calculator
//
//  Created by Brian Neil on 1/26/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import UIKit

class CalculatorGraphViewController: UIViewController, GraphViewDataSource {
    
    @IBOutlet weak var GraphViewOutlet: GraphView! {
        didSet {
            GraphViewOutlet.dataSource = self
            GraphViewOutlet.addGestureRecognizer(UIPinchGestureRecognizer(target: GraphViewOutlet, action: "zoom:"))
            GraphViewOutlet.addGestureRecognizer(UIPanGestureRecognizer(target: GraphViewOutlet, action: "slideOrigin:"))
            GraphViewOutlet.addGestureRecognizer(UITapGestureRecognizer(target: GraphViewOutlet, action: "jumpOrigin:"))
        }
    }
    
    //The model
    var numericData: (xVals: [CGFloat?], yVals: [CGFloat?]) = ([], []) {      //A tuple of the data set. This will contain the points to plot on the graph
        didSet {
            updateUI()
        }
    }
    
    func createPlotPoints (function: Double -> Double, label: String)    {
        //This will take in the function and string from the calculatorBrain and execute the function over the graph boundaries. It will set the numericData tuple at the end so that it's property observer will call the updateUI function
        var numericX: CGFloat = 0
        var pixelXMax: CGFloat         //The location of my X on the pixel system
        var pixelX: CGFloat = 0
        let origin = GraphViewOutlet.axesOrigin //This is a CGPoint
        var data: (x: [CGFloat?], y: [CGFloat?]) = ([],[])
        
        pixelXMax = GraphViewOutlet.bounds.width * GraphViewOutlet.contentScaleFactor //Goes to the other end multiplied by the content scale factor
        
        numericX -= (origin.x) * GraphViewOutlet.pointsPerUnit  //Start at the most negative point
        
        let bumpBy = GraphViewOutlet.pointsPerUnit * GraphViewOutlet.contentScaleFactor //This is in pixels
        
        while pixelX < pixelXMax {
            let yValue = CGFloat(function(Double(numericX)))
            if yValue.isNormal || yValue.isZero {
                let pixelY = (yValue - origin.y) * GraphViewOutlet.pointsPerUnit * GraphViewOutlet.contentScaleFactor
                data.y.append(pixelY)
                data.x.append(pixelX)
            } else {
                data.y.append(nil)
                data.x.append(nil)
            }
            pixelX += bumpBy
        }
        
        numericData.xVals = data.x
        numericData.yVals = data.y
        
        
        
    }
    
    func pointsForGraphView(sender: GraphView) -> ([CGFloat?], [CGFloat?]) {
        return numericData
    }
    
    
    func updateUI() {
        GraphViewOutlet.setNeedsDisplay()     //This will tell the screen to redraw
    }
}
