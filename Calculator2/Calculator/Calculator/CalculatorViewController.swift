//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Brian Neil on 1/4/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()

    
    @IBAction func assignM(sender: UIButton) {
        brain.variableValues["M"] = displayValue
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.evaluate() {
            displayValue = result
        }else {
            displayValue = nil
        }
        history.text = brain.description
    }
    
    @IBAction func pushVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            enter()
        }
        if let variable = sender.currentTitle {
            if let result = brain.pushOperand(variable) {
                displayValue = result
            } else {
                displayValue = nil
            }
            history.text = brain.description
        }
    }
    
    @IBAction func appendDigit(sender: UIButton){
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if digit != "." || display.text!.rangeOfString(".") == nil {           //if the digit is not a decimal, go ahead, or if it is a decimal, but there is no decimal already, go ahead.
             display.text = display.text! + digit
            }
        }else {
            display.text = digit                                                   //since we haven't typed anything yet, it's ok to go ahead with whatever this is, even a decimal
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clearStack()
        brain.clearVars()
        history.text = ""
        display.text = "0"
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber{
            enter()
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = nil
            }
            history.text = brain.description
        }
    }

    @IBAction func enter() {
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {      //TODO is this a safe unwrap?
            displayValue = result
        }else {
            displayValue = nil
        }
        history.text = brain.description
        
    }
    var displayValue: Double?{
        get{
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set{
            if newValue == nil              //if the contents can't be displayed, this will set the screen to 0 again.
            {
                display.text = "0"
            } else{
                display.text = "\(newValue!)"   //displayValue is a Double? so needs to be unwrapped.
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
}
