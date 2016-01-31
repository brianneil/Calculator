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
    

    let brain = CalculatorBrain()       //Create an instance of the CalcBrain Class to handle the math
    
    var functionString = ""
    
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
            brain.pushOperand(Double(numericX))     //Add the numberic value of X to the stack
            if let doubValue = brain.performOperation(functionString) { //Use the CalcBrain to evalauate the function
                let yValue = CGFloat(doubValue)
                if (yValue.isNormal || yValue.isZero) && yValue != numericX {       //Cludgy && to protect against initial case where there is no operation
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
            brain.clearStack()      //Empty out the stack so that it's ready for the next run
        }
        updateUI()
        return data

    }
    
    func updateUI() {
        GraphViewOutlet?.setNeedsDisplay()
        title = functionString + "(M)"
    }
}
