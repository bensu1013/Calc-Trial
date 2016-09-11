//
//  ViewController.swift
//  Calculator
//
//  Created by Benjamin Su on 9/9/16.
//  Copyright © 2016 Benjamin Su. All rights reserved.
//
// Testing Git hub with this file
import UIKit

class ViewController: UIViewController {
    
    var calculationString: String = ""              //Mainstring used to store all input
    var resultNumber: Double = 0                    //temporary storage after calculations
    var didOperation = false                        //Bool flag prevent multiple uses of operators in a row
    
    @IBOutlet weak var buttonDltClrLabel: UILabel!
    
    @IBOutlet weak var resultLabel: UILabel!
    //Buttons from 0 through 9
    @IBAction func buttonOne(sender: AnyObject)     { buttonPressed("1", did: false) }
    
    @IBAction func buttonTwo(sender: AnyObject)     { buttonPressed("2", did: false) }
    
    @IBAction func buttonThree(sender: AnyObject)   { buttonPressed("3", did: false) }
    
    @IBAction func buttonFour(sender: AnyObject)    { buttonPressed("4", did: false) }
    
    @IBAction func buttonFive(sender: AnyObject)    { buttonPressed("5", did: false) }
    
    @IBAction func buttonSix(sender: AnyObject)     { buttonPressed("6", did: false) }
    
    @IBAction func buttonSeven(sender: AnyObject)   { buttonPressed("7", did: false) }
    
    @IBAction func buttonEight(sender: AnyObject)   { buttonPressed("8", did: false) }
    
    @IBAction func buttonNine(sender: AnyObject)    { buttonPressed("9", did: false) }
    
    @IBAction func buttonZero(sender: AnyObject)    { buttonPressed("0", did: false) }
    //Checks to prevent two decimals in a row
    @IBAction func buttonDecimal(sender: AnyObject) {
        if calculationString.characters.last != "." {
            buttonPressed(".", did: false)
        }
    }
    //Has extra else if that will allow for negative numbers after pressing an operation button
    @IBAction func buttonSubtract(sender: AnyObject) {
        if !didOperation {
            buttonPressed("-", did: true)
        } else if calculationString.characters.last != "-" {
            buttonPressed("-", did: true)
        }
    }
    //count checks here are to prevent having an operator before numbers
    @IBAction func buttonAddition(sender: AnyObject) {
        if !didOperation && calculationString.characters.count > 0 { buttonPressed("+", did: true) }
    }
    
    @IBAction func buttonDivide(sender: AnyObject) {
        if !didOperation && calculationString.characters.count > 0 { buttonPressed("/", did: true) }
    }
    
    @IBAction func buttonMultiply(sender: AnyObject) {
        if !didOperation && calculationString.characters.count > 0 { buttonPressed("x", did: true) }
    }
    //Allows for two choices, Clr emptys mainstring, Dlt will remove last element
    @IBAction func buttonClear(sender: AnyObject) {
        let label = buttonDltClrLabel.text!
        switch label {
        case "Clr":
            clearAll()
            showResults()
        case "Dlt":
            calculationString.removeAtIndex(calculationString.endIndex.predecessor())
            if (calculationString.characters.last == "+" ||
                calculationString.characters.last == "-" ||
                calculationString.characters.last == "x" ||
                calculationString.characters.last == "/") {
                didOperation = true
            } else {
                didOperation = false
            }
            showResults()
        default:
            showResults()
        }
    }
    //equal will check and clean the main string to prevent crashes before performing calculations
    @IBAction func buttonEqual(sender: AnyObject) {
        var calcString = calculationString
        var lastIndex = calcString.characters.count - 1
        if calcString.characters.count > 2 {
            if calcString.characters.last == "-" {
                calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
                lastIndex -= 1
            }
            if (calcString.characters.last == "+" ||
                calcString.characters.last == "-" ||
                calcString.characters.last == "x" ||
                calcString.characters.last == "/") {
                    
                    calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
            }
            print(calcString)
            resultNumber = calculateAll(decipherCalc(calcString))
            calculationString = String(resultNumber)
            calculationString = shortenNumber()
            showResults()
            buttonDltClrLabel.text = "Clr"
        }
    }
    
    override func viewDidLoad()             { super.viewDidLoad() }
    
    override func didReceiveMemoryWarning() { super.didReceiveMemoryWarning() }
    
    //Seperate string in to arrays of numbers and operations
    func decipherCalc(calc: String) -> ([Double], [String]) {
        var numArray: [Double] = []
        var operationArray: [String] = []
        var tempNum: String = ""
        var canBeNegative = true
        let calcLine = calc
        for (index, digit) in calcLine.characters.enumerate() {
            if (digit == "x" || digit == "/" || digit == "-" || digit == "+") {
                if canBeNegative && digit == "-" {
                    tempNum += String(digit)
                    canBeNegative = false
                } else {
                    canBeNegative = true
                    numArray.append(Double(tempNum)!)
                    operationArray.append(String(digit))
                    tempNum = ""
                }
            } else if calcLine.characters.count - 1 == index {
                tempNum += String(digit)
                numArray.append(Double(tempNum)!)
                tempNum = ""
            } else {
                canBeNegative = false
                tempNum += String(digit)
            }
        }
        return (numArray, operationArray)
    }
    
    //Goes through array of operations and does math based on Order of Operations
    func calculateAll(numOper: ([Double], [String])) -> Double {
        var isMultiplyDivide = true
        var isAddSubtract = false
        var numArray = numOper.0
        var operArray = numOper.1
        while isMultiplyDivide {
            for (index,oper) in operArray.enumerate() {
                if (oper == "x" || oper == "/") {
                    numArray[index] = doMath(numArray, operArr: (index, oper))
                    numArray = shrinkNumberArray(numArray, removeIndex: (index + 1))
                    operArray = shrinkOperationArray(operArray, removeIndex: index)
                    break
                }
            }
            if (!operArray.contains("x") && !operArray.contains("/")) {
                isMultiplyDivide = false
                isAddSubtract = true
                break
            }
        }
        while isAddSubtract {
            for (index, oper) in operArray.enumerate() {
                if (oper == "+" || oper == "-") {
                    numArray[index] = doMath(numArray, operArr: (index, oper))
                    numArray = shrinkNumberArray(numArray, removeIndex: (index + 1))
                    operArray = shrinkOperationArray(operArray, removeIndex: index)
                    break
                }
            }
            if (!operArray.contains("+") && !operArray.contains("-")) {
                isAddSubtract = false
                break
            }
        }
        return numArray[0]
    }
    //Checks for appropriate operations to use on numbers
    func doMath(numArr: [Double], operArr: (Int, String))  -> Double{
        var results: Double = 0
        switch operArr.1 {
        case "x":
            results = multiply(numArr[operArr.0], second: numArr[operArr.0 + 1])
        case "/":
            results = divide(numArr[operArr.0], second: numArr[operArr.0 + 1])
        case "+":
            results = add(numArr[operArr.0], second: numArr[operArr.0 + 1])
        case "-":
            results = subtract(numArr[operArr.0], second: numArr[operArr.0 + 1])
        default:
            results = 0
        }
        return results
    }
    //Removes an item from array of numbers at index
    func shrinkNumberArray(numberArray: [Double], removeIndex: Int) -> [Double] {
        var numArr = numberArray
        numArr.removeAtIndex(removeIndex)
        return numArr
    }
    //Removes an item from array of operations at index
    func shrinkOperationArray(operArray: [String], removeIndex: Int) -> [String] {
        var operArr = operArray
        operArr.removeAtIndex(removeIndex)
        return operArr
    }

    //doMath function will call on these functions to perform math on two numbers
    func add(first: Double, second: Double) -> Double       {return (first + second) }
    
    func subtract(first: Double, second: Double) -> Double  {return (first - second) }
    
    func multiply(first: Double, second: Double) -> Double  {return (first * second) }
    
    func divide(first: Double, second: Double) -> Double    {return (first / second) }
    
    //clears calculationString, might do more????
    func clearAll()                                         { calculationString = "" }
    //Checks number after calculations to see if there are hanging zeroes or decimals that can be removed
    func shortenNumber() -> String {
        var didShorten = false
        var calcString = calculationString
        while !didShorten {
            var lastIndex = calcString.characters.count - 1
            if calcString.characters.contains("e") {
                var hasLetterE = true
                while hasLetterE {
                    calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
                    lastIndex -= 1
                    if !calcString.characters.contains("e") {
                        hasLetterE = false
                    }
                }
            } else if (calcString.characters.last == "0" && calcString.characters.contains(".")) &&
                calcString.characters.count > 1 {
                calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
            } else if calcString.characters.last == "." && calcString.characters.count > 1 {
                calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
            } else {
                didShorten = true
                didOperation = false
            }
        }
        return calcString
    }
    //prints the results to the resultsLabel
    func showResults() {
        if calculationString.characters.count > 0 {
            buttonDltClrLabel.text = "Dlt"
        } else {
            buttonDltClrLabel.text = "Clr"
        }
        resultLabel.text = calculationString
    }
    //called from IBActions that adds elements to the main string
    func buttonPressed(button: String, did: Bool) {
        calculationString += button
        didOperation = did
        showResults()
    }
}

