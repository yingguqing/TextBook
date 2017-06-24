//
//  BookViewController.swift
//  TextBook
//
//  Created by 影孤清 on 2017/6/24.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import UIKit

class BookViewController: UIViewController {
    
    var ruleFile:RuleFile = AppStatus.shareAppStatus.ruleFile!
    var progress:Float = 0.0
    var finishIndex:Float = 0.0
    var bookList:Array<BookEntity> = Array()
    var chapterFailArr:Array<BookEntity> = Array()
    let queue = DispatchQueue(label: "tk.bourne.testQueue", qos: .utility, attributes: DispatchQueue.Attributes.concurrent)
    
    @IBOutlet weak var lbShow: UILabel!
    @IBOutlet weak var tfDirectoryUrl: UITextField!
    @IBOutlet weak var tfBookName: UITextField!
    @IBOutlet weak var lbSelectShow: UILabel!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        lbShow.text = ruleFile.websiteDescription
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        guard tfBookName.text?.isEmpty == false && tfDirectoryUrl.text?.isEmpty == false else {
            showFailMessage(msg: "请输入小说名和目录地址")
            btnStart.isEnabled = true;
            return
        }
        UIApplication.shared.isIdleTimerDisabled = true
        ruleFile.bookName = tfBookName.text
        ruleFile.directoryUrl = cheackDirectoryUrl(url: tfDirectoryUrl.text)
        sender.isEnabled = false
        btnStart.setTitle(" ", for: .normal)
        activity.startAnimating()
        createBookFromNet()
    }

    /**
     *  @brief  从网上抓取小说
     *
     */
    func createBookFromNet() {
        var muluString = urlstringWith(url: ruleFile.directoryUrl!, isUtf8: ruleFile.directoryIsUtf8)
        guard muluString.isAnyText() else {
            showFailMessage(msg: "目录数据获取不到")
            allToDefault()
            return
        }
        finishIndex = 0
        if (ruleFile.directoryHeaderCutString?.isAnyText())! {
            muluString = cutHeaderWith(str: ruleFile.directoryHeaderCutString!, content: muluString)
        }
        let result = muluCutForRegular(content: muluString)
        if result {
            let length = bookList.count
            for item in bookList {
                loadBookText(item: item, length: UInt(length))
            }
        }
    }
    
    /**
     *  @brief  切掉前面会造成错误的文字
     *
     *  @param str      正确文字唯一的开始文字
     *  @param content  源文字
     *
     *  @return 结果
     */
    func cutHeaderWith(str:String,content:String) -> String {
        guard str.isAnyText() else {return content}
        let range = content.range(of: str)
        guard (range?.upperBound != nil) else {
            return content
        }
        
        return content.substring(from: (range?.upperBound)!)
    }
    
    /**
     *  @brief  以正则表达式来分割目录
     *  (因为不会写正则表达式,所以很少使用,不过最后还是使用这个方法,修改比较容易)
     *
     *  @param content  源文字
     *
     */
    func muluCutForRegular(content:String) -> Bool {
        guard ruleFile.titleRegexIndex >= 0 && ruleFile.urlRegexIndex >= 0 else {
            showFailMessage(msg: "先在规则里添加 标题和路径的位置")
            allToDefault()
            return false
        }
        bookList.removeAll()
        do {
            let regex = try NSRegularExpression(pattern: ruleFile.directoryRegex!, options: .caseInsensitive)
            let matches = regex.matches(in: content, options: .reportProgress, range: NSMakeRange(0, content.characters.count))
            let count = matches.count
            guard count > 0 else {
                showFailMessage(msg: "正则表达式没有匹配到任何结果")
                allToDefault()
                return false
            }
            guard count > ruleFile.titleRegexIndex && count > ruleFile.urlRegexIndex else {
                showFailMessage(msg: "标题和路径的位置错误")
                allToDefault()
                return false
            }
            var range:Range<String.Index>?
            for m in matches {
                let item = BookEntity()
                let url = content.substring(with:content.range(from: m.rangeAt(ruleFile.urlRegexIndex))!)
                range = url.range(of: "\"")
                if range?.lowerBound != nil {
                    item.url = url.substring(to: (range?.lowerBound)!)
                    range = nil
                } else {
                    item.url = url
                }
                item.title = content.substring(with:content.range(from: m.rangeAt(ruleFile.titleRegexIndex))!)
                bookList.append(item)
            }
        } catch _ {
            showFailMessage(msg: "解析目录出错")
            allToDefault()
            return false
        }
        return true;
    }
    
    /**
     *  @brief  抓取当前章节内容
     *
     *  @param item    当前章节信息
     *  @param length  总章节数
     *
     */
    func loadBookText(item:BookEntity, length:UInt) {
        queue.async {
            let url = (self.ruleFile.bookBaseUrl)! + item.url!
            var str = self.urlstringWith(url: url, isUtf8: self.ruleFile.articleisUtf8)
            self.finishIndex += 1
            var isFail = true
            if str.isAnyText() {
                str = str.replacingOccurrences(of: "&nbsp;", with: "  ")
                str = str.replacingOccurrences(of: "<br />", with: "\n")
                str = str.replacingOccurrences(of: "<br/>", with: "\n")
                str = str.replacingOccurrences(of: "\n\n;", with: "\n")
                var range = str.range(of: (self.ruleFile.articleStartString)!)//内容开始字符串
                if range?.lowerBound != nil {
                    var text = str.substring(from: range!.upperBound)
                    range = text.range(of: (self.ruleFile.articleEndString)!)//内容结束字符串
                    if range?.lowerBound != nil {
                        text = text.substring(to: (range?.lowerBound)!)
                        if text.isAnyText() {
                            item.text = text
                            isFail = false
                        }
                    }
                }
            }
            if isFail {
                self.chapterFailArr.append(item)
            }
            DispatchQueue.main.async {
                let p = self.finishIndex*100/Float(length)
                self.lbShow.text = String(format:"进度: %.2f%%",p)
                if (p >= 100) {
                    self.saveBook()
                    self.allToDefault()
                    if self.chapterFailArr.count > 0 {
                        self.showFailMessage(msg: "有章节内容没有获取成功,请查看LOG")
                        self.allToDefault()
                        print("以下章节没有获取到内容")
                        for item in self.chapterFailArr {
                            print(item.title!+item.url!)
                        }
                    }
                }
            }
        }
    }
    
    /**
     *  @brief  保存小说
     *
     */
    func saveBook() {
        var str = ""
        for item in bookList {
            str = str + item.title! + "\n" + item.text! + "\n"
        }
        let path = RuleFile.pathWith(fileName: ((ruleFile.bookName)! + ".txt"))
        do {
            try str.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
        } catch _ {
            lbShow.text = "小说写文件时失败"
        }
        lbShow.text = "小说收集完成"
    }
    
    /**
     *  @brief  通过url获取数据,内容为文字
     *
     *  @param strurl  strurl description
     *
     *  @return return description
     */
    func urlstringWith(url strurl:String , isUtf8:Bool) -> String {
        let url = URL(string: strurl)
        do {
            let data = try Data(contentsOf: url!)
            if isUtf8 {
                return String(data:data, encoding:String.Encoding.utf8)!
            } else {
                let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
                return String(data:data, encoding:String.Encoding(rawValue: enc))!
            }
        } catch _ {
            print("从网络获取数据失败  \(strurl)")
            return ""
        }
    }

    /**
     *  @brief  检查目录地址,如果有基地址就删除前面的其地址
     *
     *  @param url  目录地址
     *
     *  @return return description
     */
    func cheackDirectoryUrl(url:String?) -> String? {
        guard (ruleFile.bookBaseUrl?.isAnyText())! && (url?.hasPrefix(ruleFile.bookBaseUrl!))! else {
            return url
        }
        let index = url?.index(url!.startIndex, offsetBy: ruleFile.bookBaseUrl!.characters.count)
        return url?.substring(from: index!)
    }

    func allToDefault() {
        btnStart.setTitle("开始", for: .normal)
        btnStart.isEnabled = true;
        activity.stopAnimating()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

extension UIViewController {
    public func showFailMessage(msg:String) {
        present(message: msg, isFaild: true)
    }
    
    /**
     *  @brief  显示提示框
     *
     *  @param message  显示内容
     *  @param style    提示框类型
     *
     */
    public func present(message:String , isFaild:Bool) {
        let title = isFaild ? "失败" : "成功"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "确定", style: .default , handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
