//
//  GraphView.swift
//  Calculator
//
//  Created by Brian Neil on 1/26/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func pointsForGraphView(sender: GraphView) -> ([Double], [Double])
}

@IBDesignable
class GraphView: UIView {
    
    @IBInspectable
    var pointsPerUnit: CGFloat {
        return 50.0
    }
    
    var axesOrigin: CGPoint {
        return convertPoint(center, fromView: superview)
    }
    
    var axesBounds: CGRect {
        return convertRect(frame, fromView: superview)
    }
    
    var axes = AxesDrawer()
    
    weak var dataSource: GraphViewDataSource?
    
    //Create a UIBezierPath of the points

    override func drawRect(rect: CGRect) {
        axes.drawAxesInRect(axesBounds, origin: axesOrigin, pointsPerUnit: pointsPerUnit)       //This will draw a blank graph
    }

}
