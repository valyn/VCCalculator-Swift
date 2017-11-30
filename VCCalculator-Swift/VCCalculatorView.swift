//
//  VCCalculatorView.swift
//  VCCalculator-Swift
//
//  Created by ValynCheng on 2017/6/20.
//  Copyright © 2017年 valyncheng. All rights reserved.
//

import UIKit
import Foundation

class CalculateInput {
    open var lastInput: CalculateInput? {
        didSet{
            count += 1
        }
    }
    open var text:String = ""
    open var count: Int = 0
    open var num: Float?{
        get {
            return Float.init(text)
        }
        set{
            text = String.init(newValue!)
        }
    }
    open var isNan: Bool{
        return num != nil
    }
    init(){
        
    }
    init(input: String) {
        text = input
    }
}

class VCCalculatorView : UIView, UITableViewDelegate, UITableViewDataSource{
    
    var calculatedRecords: UITableView
    var keyboard: UIView
    
    var lastInputStr: String = ""
    var inputStr: String = "0"
    var records = [String]()
    
    let leftBracket = "("
    let rightBracket = ")"
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        calculatedRecords = UITableView.init()
        let view = Bundle.main.loadNibNamed("VCCalculatorKeyboard", owner: nil, options: nil)
        keyboard = view?.first as! UIView
        
        super.init(frame: frame)
        
        for btn in keyboard.subviews {
            if btn.isKind(of: UIButton.self) {
                let temp: UIButton = btn as! UIButton
                temp.addTarget(self, action: #selector(touchBtn(btn:)), for: UIControlEvents.touchUpInside)
            }
        }
        
        calculatedRecords.delegate = self
        calculatedRecords.dataSource = self
        self.addSubview(calculatedRecords)
        self.addSubview(keyboard)
        records.append(inputStr)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.frame.size.width
        let height = self.frame.size.height
        
        calculatedRecords.frame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size:CGSize.init(width: width, height: height * 0.5))
        keyboard.frame = CGRect.init(x: 0, y: height * 0.5, width: width, height: height * 0.5)
        
    }
    
    
    /**
     UITableViewDelegate, UITableViewDataSource
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell.init()
        cell.backgroundColor = UIColor.white
        cell.textLabel?.text = records[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
    
    /**
     event
     */
    func touchBtn(btn: UIButton){
        
        let tempStr: String = btn.currentTitle!
        
        switch tempStr {
        case "AC":
            inputStr = "0"
            lastInputStr = ""
            records = [inputStr]
            reload()
        case "delete":
            if inputStr.utf16.count >= 1 {
                inputStr = inputStr.substring(to: inputStr.index(before: inputStr.endIndex))
                lastInputStr = last(inputStr)
                reload()
            }
        case "%":
            if last(inputStr) == "." {
                inputStr.append("0")
                reload()
            }
            if isANumber(last(inputStr)) {
                let operateStr:(String, String) = findLastOperatedNum(inputStr)
                inputStr = operateStr.0 + "\((operateStr.1 as NSString).doubleValue / 100)"
                lastInputStr = last(inputStr)
                reload()
            }
        case "+/-":
            if last(inputStr) == "." {
                inputStr.append("0")
                reload()
            }
            var operateStr:(String, String) = findLastOperatedNum(inputStr)
            if last(operateStr.0) == "*" || last(operateStr.0) == "/" {
                inputStr = operateStr.0 + "(" + "-" + operateStr.1 + ")"
            } else if last(operateStr.0) == "+" {
                inputStr = removeLast(operateStr.0) + "-" + operateStr.1
            } else if operateStr.0.utf16.count == 0 && (operateStr.1 != "0") {
                //只有一个操作数时,并且该操作数为正数
                inputStr = "-" + operateStr.1
            } else if last(operateStr.0) == "-" {
                operateStr.0 = removeLast(operateStr.0)
                if last(operateStr.0) == leftBracket {
                    //负负得正，并去掉前面的括号
                    inputStr = removeLast(operateStr.0) + operateStr.1
                } else {
                    if operateStr.0.utf16.count == 0 {
                        //只有一个操作数，并且该操作数为负数
                        inputStr = operateStr.1
                    } else {
                        inputStr = operateStr.0 + "+" + operateStr.1
                    }
                }
            }
            lastInputStr = last(inputStr)
            reload()
            
        case let number where isANumber(number):
            if inputStr == "0" || (inputStr as NSString).doubleValue == 0{
                inputStr = tempStr
            } else {
                inputStr.append(tempStr)
            }
            lastInputStr = last(inputStr)
            reload()
        case ".":
            if isANumber(lastInputStr) && !findLastOperatedNum(inputStr).1.contains("."){
                if lastInputStr.utf16.count == 0 && inputStr.utf16.count == 0 {
                    inputStr.append("0.")
                } else {
                    inputStr.append(".")
                }
                lastInputStr = last(inputStr)
                reload()
            }
        case let opt where isOperator(opt):
            if isOperator(last(inputStr)) {
                inputStr = removeLast(inputStr)
                inputStr.append(tempStr)
            } else if lastInputStr == "." {
                inputStr.append("0")
            } else if isANumber(last(inputStr)) {
                inputStr.append(tempStr)
            } else if lastInputStr.utf16.count == 0 {
                inputStr.append(tempStr)
            } else if last(inputStr) == rightBracket {
                inputStr.append(tempStr)
            }
            
            lastInputStr = last(inputStr)
            reload()
            
        case "=":
            if last(inputStr) == "." {
                inputStr.append("0")
                reload()
            }
            if isANumber(last(inputStr)) || last(inputStr) == rightBracket {
                if inputStr.utf16.count >= 1 && inputStr != "0" {
                    let nums = getOperatedNums(inputStr)
                    let result = calculate(nums)
                    records.append("=" + result)
                    
                    let newIntputStr = "0"
                    records.append(newIntputStr)
                    inputStr = newIntputStr
                    calculatedRecords.reloadData()
                }
            }
        default:
            break
        }
        
    }
    
    
    
    func reload(){
        records[records.count - 1] = inputStr
        calculatedRecords.reloadData()
    }
    
    func calculate(_ para: [String]) -> String{
        
        var nums = para
        print("nums --------   ")
        print(nums)
        
        var locateIdx : Int = -1
        var index: Int = -1
        
        var highLevelOperator: Bool = false
        var copyFlag: Bool = false
        var subNums = [String]()
        
        if nums.count > 3 {
            for str in nums {
                
                index += 1
                if str == leftBracket {
                    copyFlag = true
                    locateIdx = index
                    continue
                } else if str == rightBracket {
                    copyFlag = false
                    break
                } else if isHighLevelOperator(str) {
                    if highLevelOperator == false {
                        locateIdx = index
                    }
                    highLevelOperator = true
                }
                
                if copyFlag {
                    subNums.append(str)
                }
                
            }
            
            /** 括号存在，先计算括号内容 */
            var count :Int = subNums.count
            if count > 0 {
                count = copyFlag ? count + 1 : count + 2
                let result = calculate(subNums)
                for _ in 0..<count {
                    nums.remove(at: locateIdx)
                }
                nums.insert(result, at: locateIdx)
            } else if locateIdx != -1 {
                if (locateIdx > 1) {
                    
                    let result = getCalculate(nums, index: locateIdx)
                    for _ in 0..<3 {
                        nums.remove(at: locateIdx - 1)
                    }
                    nums.insert(result, at: locateIdx - 1)
                }
            } else {
                if isOperator(nums[0]) {
                    let result = getCalculate(nums, index: -1)
                    
                    for _ in 0..<2 {
                        nums.remove(at: 0)
                    }
                    nums.insert(result, at: 0)
                } else {
                    let result = getCalculate(nums, index: 0)
                    for _ in 0..<3 {
                        nums.remove(at: 0)
                    }
                    nums.insert(result, at: 0)
                }
            }
            
            return calculate(nums)
            
        } else if nums.count == 2 {
            /** 负数 */
            let result = getCalculate(nums, index: -1)
            return result
        } else if nums.count == 3 {
            let result = getCalculate(nums, index: 0)
            return result
        }
        
        return ""
    }
    
    func getCalculate(_ arr:[String], index: Int) -> String{
        var calculationTuple: (String, String, String) = ("", "", "")
        if index == -1 {
            calculationTuple = ("0", arr[0], arr[1])
        } else if index == 0 {
            calculationTuple = (arr[0], arr[1], arr[2])
        } else if index > 1 {
            calculationTuple = (arr[index - 1], arr[index], arr[index + 1])
        }
        return calculation(calculationTuple)
    }
    
    func isHighLevelOperator(_ para: String) -> Bool {
        if para == "*" || para == "/" {
            return true
        }
        return false
    }
    
    func calculation(_ para: (String, String, String)) -> String {
        var result : Double = 0
        let opt1 = (para.0 as NSString).doubleValue
        let opt2 = (para.2 as NSString).doubleValue
        switch para.1 {
        case "+":
            result = opt1 + opt2
        case "-":
            result = opt1 - opt2
        case "*":
            result = opt1 * opt2
        case "/":
            if opt2 != 0 {
                result = opt1 / opt2
            } else {
                return ""
            }
        default:
            break
        }
        return String.init(result)
    }
    
    /** 将字符串分割成操作数，操作符，括号等，为计算做准备  */
    func getOperatedNums(_ para: String) -> [String]{
        
        var nums = [String]()
        var substr: String = ""
        var copystr = para
        
        while(copystr.utf16.count > 0) {
            
            let cpSubstr: String = first(copystr)
            if isANumber(cpSubstr) || last(substr) == "e" || cpSubstr == "." || cpSubstr == "e" {
                /**
                 如果当前字符是e，代表当前是一个指数形式的基数，直接拼接；
                 如果上个字符是e，代表这是基数的指数，直接拼接；
                 */
                substr.append(cpSubstr)
            } else {
                /**
                 除以上情况外，当前cpSubstr应是操作符，遇到操作符结束上一个数的拼接，压入数组
                 并将字符一并压入数组
                 */
                if substr.utf16.count > 0{
                    /** 此种情况下，操作符应为表示正负，substr数为空，不存入数组 */
                    nums.append(substr)
                }
                nums.append(cpSubstr)
                substr = ""
            }
            
            copystr = removeFirst(copystr)
        }
        if substr.utf16.count > 0 && copystr.utf16.count == 0 {
            nums.append(substr)
        }
        
        return nums
    }
    
    func findLastOperatedNum(_ para:String) -> (String, String){
        var copystr = para
        let nums:[String] = getOperatedNums(para)
        let toIdx = copystr.range(of: nums.last!)
        copystr = copystr.substring(to: toIdx!.lowerBound)
        return (copystr, nums.last!)
    }
    
    /** 判断字符串是否是数字 */
    func isANumber(_ para: String) -> Bool {

        if para == "0" || para == "1" || para == "2" || para == "3" || para == "4" || para == "5" || para == "6" || para == "7" || para == "8" || para == "9" {
            return true
        }
        return false
    }
    
    func isOperator(_ para: String) -> Bool {
        if para == "+" || para == "-" || para == "*" || para == "/" {
            return true
        }
        return false
    }
    
    /** 返回字符串的第一个字符 */
    func first(_ para: String) -> String{
        if para.utf16.count > 1 {
            return para.substring(to: para.index(after: para.startIndex))
        }
        return para
    }
    
    /** 返回字符串的最后一个字符 */
    func last(_ para: String) -> String{
        if para.utf16.count > 1 {
            return para.substring(from: para.index(before: para.endIndex))
        }
        return para
    }
    
    /** 移除字符串的最后一个字符 */
    func removeFirst(_ para: String) -> String{
        if para.utf16.count > 1 {
            return para.substring(from: para.index(after: para.startIndex))
        }
        return ""
    }
    

    
    /** 移除字符串的最后一个字符 */
    func removeLast(_ para: String) -> String{
        if para.utf16.count > 1 {
            return para.substring(to: para.index(before: para.endIndex))
        }
        return ""
    }
}
