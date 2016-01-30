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
    

    var functionString = ""
    
    func RunFunction (operation: String, value: Double) -> Double?{        //Takes in the string of the function. If recognized, runs the function, else returns nil
        switch operation {
        case "sin":
            return sin(value)
        case "cos":
            return cos(value)
        case "√":
            return sqrt(value)
        default: return nil
        }
    }
    
    func pointsForGraphView(sender: GraphView) -> (xValues: [CGFloat?], yValues: [CGFloat?]) {   //This is the model. It runs the function over the range of x's and returns the x and y values in pixels for graphing
        let origin = sender.axesOrigin
        var numericX: CGFloat = 0
        var pixelX: CGFloat = 0 //The location of my X on the pixel system
        let pPU = sender.pointsPerUnit
        let scaleFactor = sender.contentScaleFactor
        let originXPixels = origin.x * scaleFactor  //Go from points to pixels
        let originYPixels = origin.y * scaleFactor  //Go from points to pixesls
        let pixelXMax = sender.bounds.width * scaleFactor              //Goes to the other end multiplied by the content scale factor
        var data: (xValues: [CGFloat?], yValues: [CGFloat?]) = ([], [])        //Start nil'd
        
        numericX -= originXPixels / (pPU * scaleFactor)  //Start at the most negative point
        
        let bumpXBy = 1 / (pPU * scaleFactor) //converting pixels to real numbers
        
        while pixelX < pixelXMax {
            if let doubValue = RunFunction(functionString, value: Double(numericX)) {
                let yValue = CGFloat(doubValue)
                if yValue.isNormal || yValue.isZero {
                    let pixelY = originYPixels - (yValue * pPU * scaleFactor)
                    data.xValues.append(pixelX)
                    data.yValues.append(pixelY)
                } else {
                    data.xValues.append(nil)
                    data.yValues.append(nil)
                }
            }
            pixelX++
            numericX += bumpXBy
        }
        return data

    }
}
