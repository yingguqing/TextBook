//
//  ViewController.swift
//  TextBook
//
//  Created by 影孤清 on 2017/6/24.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var ruleFileArray:Array<RuleFile> = Array()
    var ruleFile:RuleFile?
    let queue = DispatchQueue(label: "tk.bourne.testQueue", qos: .utility, attributes: DispatchQueue.Attributes.concurrent)
    
    @IBOutlet weak var tvRuleFile: UITableView!
    @IBOutlet weak var btnRule: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        // 添加通知
        YNotification.addObserver(observer:self, selector:#selector(ViewController.reloadData), notification:.reloadRuleFileData)
    }
    
    //MARK:重新获取数据
    func reloadData() {
        ruleFileArray.removeAll()
        guard let managedContext = self.getContext() else {
            return
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName)
        do {
            let list =  try managedContext.fetch(fetchRequest) as! [RuleFileTB]
            for value:RuleFileTB in list {
                let item = RuleFile(withDbEntity: value)
                ruleFileArray.append(item)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        if ruleFileArray.count == 0 {
            if RuleFile.insertDefaultData() {
                reloadData()
            }
        }
        tvRuleFile.reloadData()
    }
    
    func deleteAllRuleFile() {
        guard let managedContext = self.getContext() else {
            return
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: EntityName)
        do {
            let list =  try managedContext.fetch(fetchRequest) as! [RuleFileTB]
            for value in list {
                managedContext.delete(value)
            }
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ruleFileArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RuleFileCellIdentifier")
        let item = ruleFileArray[indexPath.row]
        let lbTitle = cell?.viewWithTag(1) as! UILabel
        lbTitle.text = item.websiteDescription!
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = ruleFileArray[indexPath.row]
        if ruleFile == nil || ruleFile != item {
            ruleFile = item
            AppStatus.shareAppStatus.ruleFile = item
            btnRule.setTitle("修改规则", for: .normal)
        } else {
            ruleFile = nil
            AppStatus.shareAppStatus.ruleFile = nil
            btnRule.setTitle("添加规则", for: .normal)
            tableView .deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BookViewController" && AppStatus.shareAppStatus.ruleFile == nil {
            AppStatus.shareAppStatus.ruleFile = ruleFileArray[0]
        }
    }
}

extension NSObject {
    public func getContext () -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
}
