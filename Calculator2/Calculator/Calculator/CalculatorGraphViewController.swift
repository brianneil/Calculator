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
            SetFunction(functionString)
        }
    }
    
    //The model
    var numericData: ([CGFloat?]) = ([nil]) {      //A tuple of the data set. This will contain the points to plot on the graph
        didSet {
            updateUI()
        }
    }
    
    var functionString = ""
    
    func SetFunction (operation: String) {
        switch operation {
        case "sin":
            createPlotPoints({sin($0)}, label: operation)
        case "cos":
            createPlotPoints({cos($0)}, label: operation)
        case "√":
            createPlotPoints({sqrt($0)}, label: operation)
        default: break
        }
    }
    
    func createPlotPoints (function: Double -> Double, label: String)    {
        //This will take in the function and string from the calculatorBrain and execute the function over the graph boundaries. It will set numericData at the end so that it's property observer will call the updateUI function
        var numericX: CGFloat = 0
        var pixelXMax: CGFloat         //The location of my X on the pixel system
        var pixelX: CGFloat = 0
        updateUI() //This is a shitty hack to get the origin to properly place itself
        let origin = GraphViewOutlet.axesOrigin
        var data: ([CGFloat?]) = ([nil])        //Start nil'd
        
        pixelXMax = GraphViewOutlet.bounds.width * GraphViewOutlet.contentScaleFactor //Goes to the other end multiplied by the content scale factor
        
        numericX -= origin.x * GraphViewOutlet.pointsPerUnit  //Start at the most negative point
        
        let bumpXBy = 1 / (GraphViewOutlet.pointsPerUnit * GraphViewOutlet.contentScaleFactor) //converting pixels to real numbers
        
        while pixelX < pixelXMax {
            let yValue = CGFloat(function(Double(numericX)))
            if yValue.isNormal || yValue.isZero {
                let pixelY = origin.y + (yValue * GraphViewOutlet.pointsPerUnit * GraphViewOutlet.contentScaleFactor)
                data.append(pixelY)
            } else {
                data.append(nil)
            }
            pixelX++
            numericX += bumpXBy
            
        }
        
        numericData = data
        
        
        
    }
    
    func pointsForGraphView(sender: GraphView) -> ([CGFloat?]) {
        return numericData
    }
    
    
    func updateUI() {
        GraphViewOutlet.setNeedsDisplay()     //This will tell the screen to redraw
    }
}
