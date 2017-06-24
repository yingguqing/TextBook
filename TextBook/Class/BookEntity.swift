//
//  BookEntity.swift
//  TextBookFromHtml
//
//  Created by 影孤清 on 2017/6/10.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import UIKit

class BookEntity: NSObject {
    var title:String?
    var url:String?
    var text:String?
}

extension String {
    public func isAnyText() -> Bool {
        return !self.isEmpty
    }
    
    public func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
            else { return nil }
        return from ..< to
    }
    
    func appending(pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
}
