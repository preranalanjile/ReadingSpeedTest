//
//  FirstViewController.swift
//  SpeedTest
//
//  Created by  on 11/15/16.
//  Copyright © 2016 UHCL. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var wcUser: UILabel!
    @IBOutlet weak var wpm: UITextField!
    
    @IBOutlet weak var displayWord: UILabel!
    
    var timer : NSTimer?
    var counter = 0
    
    var delIndex = 0
    
    var currentUser = ""
    var speed1 = ""
    var speed2 = ""
    var speed3 = ""
    var tries = ""
    var allUpUsers = [[String:String]]()
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
        {
            let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
            let components = string.componentsSeparatedByCharactersInSet(inverseSet)
            let filtered = components.joinWithSeparator("")
            return string == filtered
        }
    
    @IBAction func startTest(sender: UIButton) {
        wpm.resignFirstResponder()
        delIndex = 0
        
        let tab3 = self.tabBarController?.viewControllers?[2] as! ThirdViewController
        var allUsers = tab3.nsDefault.arrayForKey("userDetails") as? [[String: String]]
        
        if allUsers != nil {
            let wordsPerMin = Int(wpm.text!)!
        
            /// update data
            for var user in allUsers! {
                // update wpm
                    if user["username"] == wcUser.text {
                        var updateUser = user
                        
                        /// sleep
                        let sleepTime = UInt32(updateUser["delayInSec"]!)!
                        sleep(sleepTime)
                        
                        var notries = Int(updateUser["numberOfTries"]!)!
                        notries = notries + 1
                        updateUser["numberOfTries"] = String(notries)
                        
                        if updateUser["wpmOne"] == "0"{
                            updateUser["wpmOne"] = wpm.text!
                            updateUser["lastUpdated"] = "wpmOne"
                        }else if updateUser["wpmTwo"] == "0"{
                            updateUser["wpmTwo"] = wpm.text!
                            updateUser["lastUpdated"] = "wpmTwo"
                        }else if updateUser["wpmThree"] == "0"{
                            updateUser["wpmThree"] = wpm.text!
                            updateUser["lastUpdated"] = "wpmThree"
                        }else{
                            let three = updateUser["wpmThree"]!
                            let two = updateUser["wpmTwo"]!
                            
                            updateUser["wpmOne"] = two
                            updateUser["wpmTwo"] = three
                            updateUser["wpmThree"] = wpm.text!
                            updateUser["lastUpdated"] = "wpmThree"
                            
                        }
                        
                        let wpm1 = Int(updateUser["wpmOne"]!)!
                        let wpm2 = Int(updateUser["wpmTwo"]!)!
                        let wpm3 = Int(updateUser["wpmThree"]!)!
                        
                        
                        var findHeighestWpm = [Int]()
                        findHeighestWpm.append(wpm1)
                        findHeighestWpm.append(wpm2)
                        findHeighestWpm.append(wpm3)
                        
                        updateUser["highestWpm"] = String(findHeighestWpm.maxElement()!)
                        let wpm4 = Int(updateUser["highestWpm"]!)!
                        findHeighestWpm.append(wpm4)
                        updateUser["highestWpm"] = String(findHeighestWpm.maxElement()!)
                        
                        allUsers?.removeAtIndex(delIndex)
                        allUsers?.append(updateUser)
                        tab3.nsDefault.setObject(allUsers, forKey: "userDetails")
                        tab3.nsDefault.synchronize()
                                                
                        currentUser = user["username"]!
                        tries = updateUser["numberOfTries"]!
                        speed1 = updateUser["wpmOne"]!
                        speed2 = updateUser["wpmTwo"]!
                        speed3 = updateUser["wpmThree"]!

                        let tab2 = self.tabBarController?.viewControllers?[1] as! SecondViewController
                        tab2.firstSpeed?.text = speed3
                        tab2.secondSpeed?.text = speed2
                        tab2.thirdSpeed?.text = speed1
                        tab2.triedWpm?.text = tries
                        tab2.userTable?.reloadData()
                        
                        let allUpdatedData = tab3.nsDefault.arrayForKey("userDetails") as? [[String: String]]
                        
                        
                        if allUpdatedData != nil {
                            allUpUsers = (allUpdatedData)!
                            tab2.allUserInfo = allUpdatedData!
                        }
                    }
                    delIndex += 1
                
                }

            /// update data
            let showWordTimer = 60 / Double(wordsPerMin)
            
            if let path =
                NSBundle.mainBundle().pathForResource("ReadData",
                                                      ofType: "txt") {
                if let text = try? String(
                    contentsOfFile: path,
                    encoding: NSUTF8StringEncoding) {
                    let allParas = text.componentsSeparatedByString("\n")
                    let randomIndex = Int(arc4random_uniform(UInt32(allParas.count)))
                    
                    var para = allParas[randomIndex]
                    if para == ""{
                        para = text.componentsSeparatedByString("\n").first!
                    }
                    
                    if timer == nil {
                        timer = NSTimer.scheduledTimerWithTimeInterval(showWordTimer, target: self, selector: #selector(FirstViewController.readData), userInfo: para, repeats: true)
                    
                    }
                }
            }
            
        }else{
            let alert = UIAlertController(title: "Alert", message: "Please add user in Settings tab to start the test", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    

    @IBAction func stopTest(sender: UIButton) {
        wpm.resignFirstResponder()
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        counter = 0
    }
    
    func readData(timers: NSTimer){
        let para = timers.userInfo!
        let allWords = para.componentsSeparatedByString(" ")
        let wordCount = allWords.count
        if (wordCount != 0 && counter < wordCount) {
            
                var middleWord = round(Double(allWords[counter].characters.count) / 2.0)
                if middleWord == 0.0 {
                    middleWord = 0
                }else {
                    middleWord -= 1.0
                }

                let myMutableString = NSMutableAttributedString(string: allWords[counter])
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: NSRange(location:Int(middleWord), length: 1))
                displayWord.attributedText = myMutableString
                
                counter += 1
        }else{
            if timer != nil {
                timer!.invalidate()
                timer = nil
            }
            counter = 0
        }

    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.wpm.delegate = self
        wpm.becomeFirstResponder()
        
        let tab3 = self.tabBarController?.viewControllers?[2] as! ThirdViewController
        let allUsers = tab3.nsDefault.arrayForKey("userDetails") as? [[String: String]]

        let tab2 = self.tabBarController?.viewControllers?[1] as! SecondViewController
        
        if allUsers != nil {
            tab2.allUserInfo = allUsers!
        
            let lastUser = allUsers!.last
            if lastUser != nil {
                wcUser.text = lastUser!["username"]
                wpm.text = lastUser!["defaultWpm"]
                
                currentUser = lastUser!["username"]!
                tries = lastUser!["numberOfTries"]!
                speed1 = lastUser!["wpmOne"]!
                speed2 = lastUser!["wpmTwo"]!
                speed3 = lastUser!["wpmThree"]!

            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        wpm.resignFirstResponder()
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

