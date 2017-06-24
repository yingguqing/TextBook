//
//  AllBookViewController.swift
//  TextBook
//
//  Created by 影孤清 on 2017/6/24.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import UIKit

class AllBookViewController: UITableViewController,UIDocumentInteractionControllerDelegate {
    var bookArray:Array<BookEntity> = Array()
    override func viewDidLoad() {
        super.viewDidLoad()
        let path = RuleFile.pathWith(fileName:nil)
        let enumerator = FileManager.default.enumerator(atPath: path)
        for str in enumerator! {
            let fileName = str as! String
            let item = BookEntity()
            item.title = fileName
            bookArray.append(item)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllBookIdentifier")
        let item = bookArray[indexPath.row]
        let lbTitle = cell?.viewWithTag(1) as! UILabel
        lbTitle.text = item.title!
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = bookArray[indexPath.row]
        let cachePath = RuleFile.pathWith(fileName:item.title!)
        let documentController = UIDocumentInteractionController(url: URL(fileURLWithPath: cachePath))
        documentController.uti = "public.plain-text";
        documentController.presentOpenInMenu(from: CGRect.zero, in: self.view, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "删除"
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let item = bookArray[indexPath.row]
        let path = RuleFile.pathWith(fileName:item.title!)
        var success = false
        do {
            try FileManager.default.removeItem(atPath: path)
            success = true
        } catch _ {
            print("删除文件失败")
        }
        if success {
            bookArray.remove(at: indexPath.row)
            self.tableView.reloadData()
        }
    }
}
