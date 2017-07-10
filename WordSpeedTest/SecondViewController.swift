//
//  SecondViewController.swift
//  SpeedTest
//
//  Created by  on 11/15/16.
//  Copyright © 2016 UHCL. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var allUserInfo = [[String:String]]()
    @IBOutlet weak var firstSpeed: UILabel!
    
    @IBOutlet weak var secondSpeed: UILabel!
    
    @IBOutlet weak var thirdSpeed: UILabel!
    
    @IBOutlet weak var triedWpm: UILabel!
    
    @IBOutlet weak var curUser: UILabel!
    @IBOutlet weak var userTable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        getUserData()
        
        userTable.delegate = self
        userTable.dataSource = self

    }
    
    func getUserData(){
        
        let tab1 = self.tabBarController?.viewControllers?[0] as! FirstViewController
        firstSpeed.text = tab1.speed3
        secondSpeed.text = tab1.speed2
        thirdSpeed.text = tab1.speed1
        triedWpm.text = tab1.tries
        
        let tab3 = self.tabBarController?.viewControllers?[2] as! ThirdViewController
        curUser.text = tab3.userName?.text ?? tab1.wcUser.text
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1 //one section
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "User List"
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allUserInfo.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let userIdentifier = "UserCell"
        //check to see if reusable cell exists first and use it
        let cell = tableView.dequeueReusableCellWithIdentifier(userIdentifier, forIndexPath: indexPath)
        let sortedUserData = allUserInfo.sort {
            item1, item2 in
            let date1 = item1["highestWpm"]! as NSString
            let date2 = item2["highestWpm"]! as NSString
            return date1.compare(date2 as String) == NSComparisonResult.OrderedDescending
        }
        if !allUserInfo.isEmpty && !sortedUserData.isEmpty {
            
            let user = sortedUserData[indexPath.row]
            if !user.isEmpty {
                cell.textLabel!.text = user["username"]!
                cell.detailTextLabel!.text = user["highestWpm"]!
            }
        }
        return cell
        
    }
    
    
//    @IBAction func refresh(sender: UIButton) {
//        userTable.reloadData()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

