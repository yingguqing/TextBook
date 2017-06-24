//
//  RuleFileTB+CoreDataProperties.swift
//  TextBook
//
//  Created by 影孤清 on 2017/6/24.
//  Copyright © 2017年 影孤清. All rights reserved.
//

import Foundation
import CoreData


let EntityName = "RuleFileTB"


enum DBResultType {
    case Error
    case Insert
    case Updata
    case Query
}

extension RuleFileTB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RuleFileTB> {
        return NSFetchRequest<RuleFileTB>(entityName: "RuleFileTB")
    }

    @NSManaged public var articleEndString: String?
    @NSManaged public var articleisUtf8: Bool
    @NSManaged public var articleStartString: String?
    @NSManaged public var bookBaseUrl: String?
    @NSManaged public var directoryHeaderCutString: String?
    @NSManaged public var directoryIsUtf8: Bool
    @NSManaged public var directoryRegex: String?
    @NSManaged public var id: Int64
    @NSManaged public var titleRegexIndex: Int64
    @NSManaged public var urlRegexIndex: Int64
    @NSManaged public var websiteDescription: String?

}
