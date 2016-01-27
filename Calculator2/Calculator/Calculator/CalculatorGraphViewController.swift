//
//  CalculatorGraphViewController.swift
//  Calculator
//
//  Created by Brian Neil on 1/26/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import UIKit

class CalculatorGraphViewController: UIViewController {
    
    //The model
    var numericData: (xVals: [Double], yVals: [Double]) = ([], []) {      //A tuple of the data set. This will contain x's and y's not mapped to pixels
        didSet {
            updateUI()
        }
    }
    
    private func getValues(graphbounds: CGRect, stepSize: Double, scaleFactor: Double, operation: String) -> ([Double], [Double])
    {
        return ([], [])
    }
    
    func updateUI() {
        //do something
    }
    
    
    
}
