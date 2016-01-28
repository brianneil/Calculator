//
//  GraphView.swift
//  Calculator
//
//  Created by Brian Neil on 1/26/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func pointsForGraphView(sender: GraphView) -> ([CGFloat?], [CGFloat?])
}

@IBDesignable
class GraphView: UIView {
    
    var needsSetup: Bool = true
    
    @IBInspectable
    var pointsPerUnit: CGFloat = 100 { didSet {setNeedsDisplay() } }
    
    var axesOrigin: CGPoint = CGPointMake(CGFloat(0.0), CGFloat(0.0)) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var axesBounds: CGRect = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0)) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private enum Constants {
        static let translationFactor: CGFloat = 2
    }
    
    
    func zoom(gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            pointsPerUnit *= gesture.scale
            gesture.scale = 1
        default: break
        }
    }
    
    func slideOrigin(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            let translation = gesture.translationInView(self)                   //Grab the tanslation, reduce it by a constant factor, if something actually moved, add the factored translation to the current origin and reset the translation value
            let xTranslation = translation.x / Constants.translationFactor
            let yTranslation = translation.y / Constants.translationFactor
            if xTranslation != 0 || yTranslation != 0 {
                axesOrigin.x += xTranslation
                axesOrigin.y += yTranslation
                gesture.setTranslation(CGPointZero, inView: self)
            }
            
        default: break
        }
    }
    
    func jumpOrigin(gesture: UITapGestureRecognizer) {
        gesture.numberOfTapsRequired = 2        //Requires a double tap
        switch gesture.state {
        case .Ended:
            let tapSpot = gesture.locationInView(self)
            axesOrigin.x = tapSpot.x
            axesOrigin.y = tapSpot.y
        default: break
        }
    }
    
    var axes = AxesDrawer()
    
    weak var dataSource: GraphViewDataSource?

    override func drawRect(rect: CGRect) {
        if needsSetup{         //First time through will put things in place and then leave them alone after
            axesOrigin = convertPoint(center, fromView: superview)
            axesBounds = convertRect(frame, fromView: superview)
            needsSetup = false
        }
        
        
        axes.drawAxesInRect(axesBounds, origin: axesOrigin, pointsPerUnit: pointsPerUnit)       //This will draw a blank graph
        
//        let graphablePixels: (xPixels: [Double], yPixels: [Double]) = (dataSource?.pointsForGraphView(self))! ?? ([0.0],[0.0])
        
//        for xPosition in graphablePixels.xPixels {
            
//        }
//    }
    }
}