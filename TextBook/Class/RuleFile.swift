//
//  RuleFile.swift
//  TextBookFromHtml
//
//  Created by 影孤清 on 2017/6/10.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import UIKit
import CoreData

fileprivate enum RuleKey {
    static let BookBaseURLKey = "小说源网址"
    static let DirectoryHeaderCutStringKey = "目录保留开始"
    static let DirectoryEncodingKey = "目录读取格式"//(UTF-8等)
    static let DirectoryRegexKey = "目录正则表达式"
    static let TitleRegexInxexKey = "标题正则位置"
    static let URLRegexInxexKey = "路径正则位置"
    static let ArticleEncodingKey = "文章读取格式"
    static let ArticleStartStringKey = "文章开始"
    static let ArticleEndStringKey = "文章结束"
    static let WebsiteDescriptionKey = "小说网站说明"
    static let RuleFileName = "BookRule.plist"
}

class RuleFile: NSObject {
    var bookName:String?//小说名
    var bookBaseUrl:String?
    private var _directoryUrl:String? //小说目录地址
    var directoryUrl:String? {//小说目录地址
        set(newValue) {
            _directoryUrl = newValue
        }
        get {
            return bookBaseUrl! + _directoryUrl!
        }
    }
    var directoryIsUtf8 = true//目录读取格式(UTF-8等)
    var directoryHeaderCutString:String?//目录开头去掉文字位置
    var directoryRegex:String?//目录正则表达式
    var titleRegexIndex:Int = -1//标题正则位置
    var urlRegexIndex:Int = -1//路径正则位置
    var articleisUtf8 = true//内容读取格式(UTF-8等)
    var articleStartString:String?//内容开始字符串
    var articleEndString:String?//内容结束字符串
    var websiteDescription:String?//小说网站说明
    
    init(withDbEntity entity:RuleFileTB?) {
        super.init()
        if entity?.bookBaseUrl?.isEmpty == false {
            bookBaseUrl = entity?.bookBaseUrl
            directoryHeaderCutString = entity?.directoryHeaderCutString
            directoryIsUtf8 = (entity?.directoryIsUtf8)!
            directoryRegex = entity?.directoryRegex
            titleRegexIndex = Int((entity?.titleRegexIndex)!)
            urlRegexIndex = Int((entity?.urlRegexIndex)!)
            articleisUtf8 = (entity?.articleisUtf8)!
            articleStartString = entity?.articleStartString
            articleEndString = entity?.articleEndString
            websiteDescription = entity?.websiteDescription
        }
    }
    
    static func pathWith(fileName:String?) ->String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0]
        if (fileName?.isEmpty == false) {
            return path.appending(pathComponent:fileName!)
        }
        return path
    }
    
    static func insertDefaultData() -> Bool {
        let path = Bundle.main.path(forResource: RuleKey.RuleFileName, ofType: "")
        guard path?.isEmpty == false else {
            return false
        }
        let dictionary = NSDictionary(contentsOfFile: path!)
        guard (dictionary?.count)! > 0 else {
            return false
        }
        guard let managedContext = dictionary!.getContext() else {
            return false
        }
        for (_,value) in dictionary! {
            let dic = value as! NSDictionary
            do{
                let file = NSEntityDescription.insertNewObject(forEntityName: "RuleFileTB", into: managedContext) as! RuleFileTB
                file.bookBaseUrl = dic[RuleKey.BookBaseURLKey] as? String
                file.directoryHeaderCutString = dic[RuleKey.DirectoryHeaderCutStringKey] as? String
                file.directoryIsUtf8 = Int(dic[RuleKey.DirectoryEncodingKey] as! NSNumber) == 4
                file.directoryRegex = dic[RuleKey.DirectoryRegexKey] as? String
                if let index = dic[RuleKey.TitleRegexInxexKey] as? NSNumber {
                    file.titleRegexIndex = Int64(index)
                } else {
                    file.titleRegexIndex = -1
                }
                if let index = dic[RuleKey.URLRegexInxexKey] as? NSNumber {
                    file.urlRegexIndex = Int64(index)
                } else {
                    file.urlRegexIndex = -1
                }
                file.articleisUtf8 = Int(dic[RuleKey.ArticleEncodingKey] as! NSNumber) == 4
                file.articleStartString = dic[RuleKey.ArticleStartStringKey] as? String
                file.articleEndString = dic[RuleKey.ArticleEndStringKey] as? String
                file.websiteDescription = dic[RuleKey.WebsiteDescriptionKey] as? String
                try managedContext.save()
            } catch let error as NSError {
                print("创建初始数据失败. \(error), \(error.userInfo)")
                return false
            }
        }
        return true
    }
}




