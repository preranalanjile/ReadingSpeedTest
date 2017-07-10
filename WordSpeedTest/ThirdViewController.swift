//
//  ThirdViewController.swift
//  SpeedTest
//
//  Created by  on 11/15/16.
//  Copyright © 2016 UHCL. All rights reserved.
//

import UIKit

class ThirdViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    var username = ""
    var delayInSec = ""
    var wcUserName = ""
    var defaultWPM = ""
    var allUserDetails = [[String: String]]()
    var nameFlag = false
    var switchToName = [String]()
    
    var selectedRow = 0
    
    @IBOutlet weak var userName: UITextField!
    
    @IBOutlet weak var defaultWpm: UITextField!
    
    @IBOutlet weak var delay: UITextField!
    
    @IBOutlet weak var switchUsers: UIPickerView!
    
    var nsDefault = NSUserDefaults()
    var userInfo: [[String: String]] = []
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    {
        let inverseSet = NSCharacterSet(charactersInString:"0123456789").invertedSet
        let components = string.componentsSeparatedByCharactersInSet(inverseSet)
        let filtered = components.joinWithSeparator("")
        return string == filtered
    }
    
    
    @IBAction func addUser(sender: UIButton) {
        userName.userInteractionEnabled = true
        nameFlag = false
        userName.text = ""
        defaultWpm.text = ""
        delay.text = ""
    }
    
    @IBAction func Save(sender: UIButton) {
        username = userName.text!
        defaultWPM = defaultWpm.text!
        delayInSec = delay.text!
        
        if username != "" && defaultWpm != "" && delayInSec != ""{
            var allUsers = nsDefault.arrayForKey("userDetails") as? [[String: String]]
            if allUsers != nil {
                userInfo = allUsers!
            
                for user in allUsers! {
                    if user["username"] == username {
                        nameFlag = true
                    }
                }
            }
            if !nameFlag {
                userInfo.append(["username": username, "defaultWpm": defaultWPM, "delayInSec": delayInSec, "wpmOne": "0", "wpmTwo": "0", "wpmThree": "0", "highestWpm": "0", "lastUpdated": "", "numberOfTries": "0"])
                
                nsDefault.setObject(userInfo, forKey: "userDetails")
                nsDefault.synchronize()
                
                allUsers = nsDefault.arrayForKey("userDetails") as? [[String: String]]
                
                // Update UI Picker
                if allUsers != nil {
                    for pickUser in allUsers! {
                        if !switchToName.contains(pickUser["username"]!){
                            switchToName.append(pickUser["username"]!)
                        }
                    }
                
                    // Reload UI Picker with updated values
                    switchUsers.reloadAllComponents()
                    
                    let lastUser = allUsers?.last
                    wcUserName = lastUser!["username"]!
                    
                    let tab2 = self.tabBarController?.viewControllers?[1] as! SecondViewController
                    tab2.curUser?.text = userName.text!
                    tab2.firstSpeed?.text = lastUser!["wpmThree"]!
                    tab2.secondSpeed?.text = lastUser!["wpmTwo"]!
                    tab2.thirdSpeed?.text = lastUser!["wpmOne"]!
                    tab2.triedWpm?.text = lastUser!["numberOfTries"]!
                    tab2.allUserInfo = allUsers!
                    tab2.userTable?.reloadData()
                    
                    let tab1 = self.tabBarController?.viewControllers?[0] as! FirstViewController
                    tab1.wcUser.text = wcUserName
                    userName.userInteractionEnabled = false
                    
                    if switchToName.contains(lastUser!["username"]!) {
                        selectedRow = switchToName.indexOf(lastUser!["username"]!)!
                        switchUsers.selectRow(selectedRow, inComponent: 0, animated: false)
                    }
                    
                }
            }else{
                let alert = UIAlertController(title: "Alert", message: "Username already exists", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }else{
            let alert = UIAlertController(title: "Alert", message: "Please fill all the data", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    var delIndex = 0
    
    @IBAction func update(sender: UIButton) {
        delIndex = 0
        var existFlag = false
        var allUsers = nsDefault.arrayForKey("userDetails") as? [[String: String]]
        username = userName.text!
        defaultWPM = defaultWpm.text!
        delayInSec = delay.text!
        if allUsers != nil {
            for var user in allUsers! {
                var updateUser = user

                if user["username"]! == userName.text! {
                    existFlag = true
                    if defaultWpm.text! != "" {
                        updateUser["defaultWpm"] = defaultWpm.text!
                    }else{
                        updateUser["defaultWpm"] = "100"
                    }
                    if delay.text! != "" {
                        updateUser["delayInSec"] = delay.text!
                    }else{
                        updateUser["delayInSec"] = "1"
                    }
                    
                    allUsers?.removeAtIndex(delIndex)
                    allUsers?.append(updateUser)
                    nsDefault.setObject(allUsers, forKey: "userDetails")
                    nsDefault.synchronize()
                    
                    let tab2 = self.tabBarController?.viewControllers?[1] as! SecondViewController
                    //tab2.curUser?.text = userName.text!
                    tab2.firstSpeed?.text = updateUser["wpmThree"]!
                    tab2.secondSpeed?.text = updateUser["wpmTwo"]!
                    tab2.thirdSpeed?.text = updateUser["wpmOne"]!
                    tab2.triedWpm?.text = updateUser["numberOfTries"]!
                    let allUpUsers = nsDefault.arrayForKey("userDetails") as? [[String: String]]
                    tab2.allUserInfo = allUpUsers!
                    tab2.userTable?.reloadData()
                    
                    let tab1 = self.tabBarController?.viewControllers?[0] as! FirstViewController
                    tab1.wpm.text = defaultWPM
                }
                delIndex += 1
            }
            if !existFlag {
                let alert = UIAlertController(title: "Alert", message: "Please save the changes before updating", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            

        }else{
            let alert = UIAlertController(title: "Alert", message: "Please save the changes before updating", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    //// User UI Picker Start
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return switchToName.count
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(string: switchToName[row], attributes: [NSForegroundColorAttributeName : UIColor.greenColor()])
        return attributedString
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return switchToName[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userName.text = switchToName[row]
        let allUsers = nsDefault.arrayForKey("userDetails") as? [[String: String]]
        if allUsers != nil {
            for user in allUsers!{
                if user["username"]! == switchToName[row] {
                    defaultWpm.text! = user["defaultWpm"]!
                    delay.text! = user["delayInSec"]!
                    username = user["username"]!
                    defaultWPM = user["defaultWpm"]!
                    
                    let tab2 = self.tabBarController?.viewControllers?[1] as! SecondViewController
                    tab2.curUser?.text = username
                    tab2.firstSpeed?.text = user["wpmThree"]!
                    tab2.secondSpeed?.text = user["wpmTwo"]!
                    tab2.thirdSpeed?.text = user["wpmOne"]!
                    tab2.triedWpm?.text = user["numberOfTries"]!
                    
                    let tab1 = self.tabBarController?.viewControllers?[0] as! FirstViewController
                    tab1.wcUser.text = username
                    tab1.wpm.text = defaultWPM
                }
            }
            selectedRow = row
        }
    }
    
    // UI Picker End
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.becomeFirstResponder()
        self.defaultWpm.delegate = self
        self.delay.delegate = self
        
        self.switchUsers.delegate = self
        self.switchUsers.dataSource = self
        
        // Fill Settings form with last user
        let allUsers = nsDefault.arrayForKey("userDetails") as? [[String: String]]
        if allUsers != nil {
            for user in allUsers! {
                switchToName.append(user["username"]!)
            }
            let lastUser = allUsers?.last
            if lastUser != nil {
                username = lastUser!["username"]!
                defaultWPM = lastUser!["defaultWpm"]!
                userName.text = lastUser!["username"]
                defaultWpm.text = lastUser!["defaultWpm"]
                delay.text = lastUser!["delayInSec"]
                
                let tab1 = self.tabBarController?.viewControllers?[0] as! FirstViewController
                tab1.wcUser.text = lastUser!["username"]
                tab1.wpm.text = lastUser!["defaultWpm"]
                userName.userInteractionEnabled = false
                
                if switchToName.contains(lastUser!["username"]!) {
                    selectedRow = switchToName.indexOf(lastUser!["username"]!)!
                    switchUsers.selectRow(selectedRow, inComponent: 0, animated: false)
                }
                
                
            }else{
                username = ""
                userName.userInteractionEnabled = true
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        userName.resignFirstResponder()
        defaultWpm.resignFirstResponder()
        delay.resignFirstResponder()
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
