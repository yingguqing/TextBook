//
//  RuleFileViewController.swift
//  TextBook
//
//  Created by 影孤清 on 2017/6/24.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import UIKit
import CoreData

class RuleFileViewController: UIViewController {
    var ruleFile:RuleFile? = AppStatus.shareAppStatus.ruleFile
    var isExist:Bool = false
    
    @IBOutlet weak var tfWebsiteDescript: UITextField!
    @IBOutlet weak var tfBaseURL: UITextField!
    @IBOutlet weak var tfDirectoryHeaderCut: UITextField!
    @IBOutlet weak var SwDirectory: UISwitch!
    @IBOutlet weak var tfDirectoryRegex: UITextField!
    @IBOutlet weak var tfArticleStart: UITextField!
    @IBOutlet weak var tfArticleEnd: UITextField!
    @IBOutlet weak var tfTitleIndex: UITextField!
    @IBOutlet weak var tfUrlIndex: UITextField!
    @IBOutlet weak var swArticle: UISwitch!
    @IBOutlet weak var btnRule: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ruleFile != nil {
            tfWebsiteDescript.text = ruleFile!.websiteDescription!
            tfBaseURL.text = ruleFile!.bookBaseUrl!
            tfDirectoryHeaderCut.text = ruleFile!.directoryHeaderCutString!
            SwDirectory.isOn = ruleFile!.directoryIsUtf8
            tfDirectoryRegex.text = ruleFile!.directoryRegex!
            tfTitleIndex.text = String(format: "%d", ruleFile!.titleRegexIndex)
            tfUrlIndex.text = String(format: "%d", ruleFile!.urlRegexIndex)
            tfArticleStart.text = ruleFile!.articleStartString!
            tfArticleEnd.text = ruleFile!.articleEndString!
            swArticle.isOn = ruleFile!.articleisUtf8
            btnRule.setTitle("修改规则", for: .normal)
        } else {
            btnRule.setTitle("添加规则", for: .normal)
        }
    }

    @IBAction func ruleAction(_ sender: UIButton) {
        guard (tfWebsiteDescript.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--网站名称")
            return
        }
        guard (tfBaseURL.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--小说网站主地址")
            return
        }
        guard (tfDirectoryRegex.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--目录正则表达式")
            return
        }
        guard (tfTitleIndex.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--标题位置")
            return
        }
        guard (tfUrlIndex.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--路径位置")
            return
        }
        guard (tfArticleStart.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--文章开始")
            return
        }
        guard (tfArticleEnd.text?.isAnyText())! else {
            self.showFailMessage(msg: "请输入--文章结束")
            return
        }
        
        YNotification.postNotification(notification: .reloadRuleFileData)
        switch updateOrInsertRuleFile() {
        case DBResultType.Error:
            self.showFailMessage(msg: "操作数据库失败")
            break
        case DBResultType.Insert:
            self.present(message: "添加新规则成功", isFaild: false)
            break
        case DBResultType.Updata:
            self.present(message: "修改规则成功", isFaild: false)
            break
        default: break
        }
    }
    
    /**
     *  @brief  修改规则信息,如果没有就是新增
     *
     *  @param file  file description
     *
     */
    func updateOrInsertRuleFile() -> DBResultType {
        guard let managedContext = self.getContext() else {
            return .Error
        }
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: EntityName)
        let entity:NSEntityDescription = NSEntityDescription.entity(forEntityName: EntityName, in: managedContext)!
        
        let baseUrl = tfBaseURL.text
        let condition = "bookBaseUrl='" + baseUrl! + "'"
        let predicate = NSPredicate(format: condition,"")
        request.entity = entity
        request.predicate = predicate
        var type:DBResultType = .Error
        do{
            let userList = try managedContext.fetch(request) as! [RuleFileTB] as Array
            var ruleFile:RuleFileTB?
            if userList.count != 0 {
                ruleFile = userList[0]
                type = .Updata
            } else{
                ruleFile = NSEntityDescription.insertNewObject(forEntityName: EntityName, into: managedContext) as? RuleFileTB
                type = .Insert
            }
            let file = ruleFile!
            file.bookBaseUrl = baseUrl;	// 小说网站地址
            file.directoryIsUtf8 = SwDirectory.isOn
            file.directoryHeaderCutString = tfDirectoryHeaderCut.text// 目录开头去掉文字位置
            file.directoryRegex = tfDirectoryRegex.text// 目录正则表达式
            file.titleRegexIndex = Int64(tfTitleIndex.text!)!
            file.urlRegexIndex = Int64(tfUrlIndex.text!)!
            file.articleisUtf8 = swArticle.isOn
            file.articleStartString = tfArticleStart.text	// 内容开始字符串
            file.articleEndString = tfArticleEnd.text	// 内容结束字符串
            file.websiteDescription = tfWebsiteDescript.text	// 小说网站说明
            try managedContext.save()
        } catch {
            return .Error
        }
        return type
    }
    
    @IBAction func tapGestureAction(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
