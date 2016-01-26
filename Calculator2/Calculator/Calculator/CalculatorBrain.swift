//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Brian Neil on 1/5/16.
//  Copyright © 2016 Apollo Hearing. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private enum Op: CustomStringConvertible {                                               //The data type for the stack.
        case Operand(Double)                                        //Just a number
        case unaryOperation(String, Double -> Double)               //A function with 1 variable
        case binaryOperation(String, (Double, Double) -> Double)    //A function with 2 variables
        case constant(String, Double)                               //Contains the symbol and it's value
        case variable(String)                                       //Contains the symbol, value will be captured in a dictionary.
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .unaryOperation(let symbol, _):
                    return symbol
                case .binaryOperation(let symbol, _):
                    return symbol
                case .constant(let symbol, _):
                    return symbol
                case .variable(let symbol):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]()                //The high level stack with all the stuff on it.
    private var knownOps = [String:Op]()        //A dictionary of operations (including constants)
    var variableValues = [String:Double]()      //Public so that users can access it
    
    init()  {
        func learnOp(op: Op) {
            var symbol: String?
            switch op {
            case .unaryOperation(let symbolVar, _):
                symbol = symbolVar
            case .binaryOperation(let symbolVar, _):
                symbol = symbolVar
            case .constant(let symbolVar, _):
                symbol = symbolVar
            case .variable(let symbolVar):
                symbol = symbolVar
            default:
                break
            }
            
            if symbol != nil {
                knownOps[symbol!] = op
            }
        }
        
        learnOp(Op.binaryOperation("×", {$1 * $0}))
        learnOp(Op.binaryOperation("÷", {$1 / $0}))
        learnOp(Op.binaryOperation("+", {$1 + $0}))
        learnOp(Op.binaryOperation("−", {$1 - $0}))
        learnOp(Op.unaryOperation("√", {sqrt($0)}))
        learnOp(Op.unaryOperation("cos", {cos($0)}))
        learnOp(Op.unaryOperation("sin", {sin($0)}))
        learnOp(Op.constant("π", M_PI))

    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList { //Guaranteed to be a property list
        get{
            return opStack.map {$0.description}     //This creates an array of strings with the descriptions
        }
        set {
            if let opSymbols = newValue as? Array<String> { //If what I'm getting (newValue) is actually an array of strings
                var newOpStack = [Op]() //Create a new stack of Ops
                for opSymbol in opSymbols { //cycle through the things in the array we got passed
                    if let op = knownOps[opSymbol] {       //If it's a symbol we know, throw it on the stack
                        newOpStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue { //If it's a number, give me the double
                        newOpStack.append(.Operand(operand))    //Put it onto the stack as an operand
                    }
                }
                opStack = newOpStack        //Sets the variable (defined way above)
            }
        }
    }
    
    private func evaluateRecursive(ops: [Op]) -> (result: Double?, remainingOps: [Op])
    {
        if !ops.isEmpty {                       //only continues if the stack has values
            var remainingOps = ops              //We have to make a copy of the ops stack that was passed in because it is always passed in as a constant
            let op = remainingOps.removeLast()  //Pop the last value off of the stack
            switch op {
            case .Operand(let operand):         //If the value is an operand, just return the number and keep going
                return(operand, remainingOps)
            case .unaryOperation(_, let operation):
                let operandEvaluation = evaluateRecursive(remainingOps)             //Look until you hit an operand
                if let operand = operandEvaluation.result {                         //If you hit an operand before you run out of stack, evaluate it by running the passed function on the operand
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .binaryOperation(_, let operation):
                let op1Evaluation = evaluateRecursive(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluateRecursive(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            case .constant(_, let value):               //similar to an operand, we just want to return the value of the constant
                return(value, remainingOps)
            case .variable(let symbol):
                if let value = variableValues[symbol] { //checks to see if the variable exists in the known list. If so, returns the value, if not, returns nil
                    return (value, remainingOps)
                } else {
                    return(nil, remainingOps)
                }
            }
        }
        
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let(result, _) = evaluateRecursive(opStack)
        //print("\(opStack) = \(result) with \(remainder) left over.")
        return result
    }
    
    func pushOperand(operand: Double) -> Double?{              //How a number gets added to the stack
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {             //For pushing user defined variables onto the stack
        opStack.append(Op.variable(symbol))                  //Push the symbol for the variable onto the stack.
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double?{             //Confirms that the operation is a known one and then puts it on the stack and performs it. If constant, should just put on the stack
        if let operation = knownOps[symbol] {            //Uses the symbol as a key in the knownOps dictionary and continues if non-nil
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func giveHistory() -> String {
        return "\(opStack)"
    }
    
    func clearStack() {
        opStack.removeAll()
    }
    
    func clearVars() {
        variableValues.removeAll()
    }
    
    private func buildRecursively(ops: [Op]) -> (resultantString: String?, remainderStack: [Op]){
        var remainingOps = ops              //We have to make a copy of the ops stack that was passed in because it is always passed in as a constant
        var stringVar = ""                  //An empty string to build up
        if !ops.isEmpty {
            let op = remainingOps.removeLast()  //Pop the last value off of the stack
            switch op {
            case .Operand(let operand):                                     //Just return the operand
                return("\(operand)", remainingOps)
            case .unaryOperation(let symbol, _):
                stringVar += symbol
                stringVar += "("
                let opEvaluation = buildRecursively(remainingOps)
                if let operand1 = opEvaluation.resultantString {
                    stringVar += operand1
                }else{
                    stringVar = "?"
                }
                stringVar += ")"
                return (stringVar, opEvaluation.remainderStack)
            case .binaryOperation(let symbol, _):
                let op1Evaluation = buildRecursively(remainingOps)
                if let operand1 = op1Evaluation.resultantString {
                    let op2Evaluation = buildRecursively(op1Evaluation.remainderStack)
                    if let operand2 = op2Evaluation.resultantString {
                        stringVar = stringVar + "(" + operand2 + symbol + operand1 + ")"
                    } else {
                        stringVar = stringVar + "(" + "?" + symbol + operand1 + ")"
                    }
                    return (stringVar, op2Evaluation.remainderStack)
                }else{
                    stringVar = "(?" + symbol + "?)"
                    return(stringVar, op1Evaluation.remainderStack)
                }
                case .constant(let symbol, _):               //similar to an operand, we just want to return the value of the constant
                return(symbol, remainingOps)
            case .variable(let symbol):
                return (symbol, remainingOps)       //Returns the variable name
            }
        }
        return (nil, ops)
    }


    private func buildDescription() -> String {
        var remainingOps = opStack
        var bigString = " "                 //Start with an empty string to build with
        while !remainingOps.isEmpty {
            let stringBuild = buildRecursively(remainingOps)
            if let newString = stringBuild.resultantString{
                if bigString == " "{            //The empty string is a space
                    bigString = newString
                }else {
                    bigString = newString + "," + bigString
                }
            }
            remainingOps = stringBuild.remainderStack
        }
        bigString += "="
        return bigString
    }
    
    var description: String {
        get{
            return(buildDescription())
        }
    }
}
