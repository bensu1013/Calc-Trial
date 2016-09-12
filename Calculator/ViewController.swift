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
    
    var deleteTimer = NSTimer()                 //This boy right here. Don't start with this boy, he will get outta control
    var holdDeleteTimer = 0                     //Hold on Jack. Never let go.
    var calculationString: String = ""          //Mainstring used to store all input
    var resultNumber: Double = 0                //temporary storage after calculations
    var didOperation = false                    //Bool flag prevent multiple uses of operators in a row
    @IBOutlet weak var resultLabel: UILabel!    //Where I show all my inputs
    //Buttons from 0 through 9
    @IBAction func buttonNumber(sender: AnyObject) {
        if let number = sender.currentTitle! {
            buttonPressed(number, did: false)
        }
    }
    //Checks to prevent two decimals in a row
    @IBAction func buttonDecimal(sender: AnyObject) {
        if calculationString.characters.last != "." {
            buttonPressed(".", did: false)
        }
    }
    //A lonely lonely button.  Will never share the warmth of others. Solitude defines you
    //Such a negative feeling you emit
    @IBAction func buttonSubtract(sender: AnyObject) {
        if !didOperation {
            buttonPressed("-", did: true)
        } else if calculationString.characters.last != "-" {
            buttonPressed("-", did: true)
        }
    }
    //Button handles all operations aside from subtract because I had that one.
    //It deserves to be alone forever! >=(
    @IBAction func buttonOperations(sender: AnyObject) {
        if let operation = sender.currentTitle! {
        if !didOperation && calculationString.characters.count > 0 {
            buttonPressed(operation, did: true)
            }
        }
    }
    //Starts timer for Clear to check against.
    @IBAction func buttonClearStart(sender: AnyObject) {
        deleteTimer.invalidate()
        deleteTimer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector:#selector(holdDeleteTimeSetter), userInfo: nil, repeats: true)
    }
    //Tapping will delete 1 element from string, holding will delete whole string
    @IBAction func buttonClearEnd(sender: AnyObject) {
        deleteTimer.invalidate()
        if holdDeleteTimer > 2 {
            print("Clear")
            holdDeleteTimer = 0
            clearAll()
            showResults()
        } else if !calculationString.isEmpty{
            print("Delete")
            holdDeleteTimer = 0
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
        }
    }
    //equal will check and clean the main string to prevent crashes before performing calculations
    @IBAction func buttonEqual(sender: AnyObject) {
        print("\(sender.currentTitle)")
        var calcString = calculationString
        var lastIndex = calcString.characters.count - 1
        if calcString.characters.count > 2 {
            if calcString.characters.last == "-" {
                calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
                lastIndex -= 1
            }
            if (calcString.characters.last == "+" || calcString.characters.last == "-" ||
                calcString.characters.last == "x" || calcString.characters.last == "/") {
                    calcString.removeAtIndex(calcString.startIndex.advancedBy(lastIndex))
            }
            resultNumber = calculateAll(decipherCalc(calcString))
            calculationString = String(resultNumber)
            calculationString = shortenNumber()
            showResults()
        }
    }
    //Overrides stuff I don't understand. so..
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
    //PEMDAS with out the parenthesis or exponents.. but still the same..  MDAS?
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
    func add(first: Double, second: Double) -> Double           {return (first + second) }
    func subtract(first: Double, second: Double) -> Double      {return (first - second) }
    func multiply(first: Double, second: Double) -> Double      {return (first * second) }
    func divide(first: Double, second: Double) -> Double        {return (first / second) }
    //clears calculationString, might do more????  This is a pathetic function. Feel ashamed
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
        resultLabel.text = calculationString
    }
    //Adds next string element to the main calculationString that I have overcomplicated and bloated. 
    //Who's crying? Not me! You're crying!!
    func buttonPressed(button: String, did: Bool) {
        calculationString += button
        didOperation = did
        showResults()
    }
    //increased depending on how long you hold on to Delete
    func holdDeleteTimeSetter() {
        holdDeleteTimer += 1
    }
}

