//
//  Chapter.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/12.
//
//

import Foundation
import PerfectLib

public class Chapter: JSONConvertibleObject {
    var id: String?                 //章节在mongodb中的oid
    var bookID: String?             //书籍在mongodb中的oid
    var name: String?               //章节名
    var href: String?               //章节网页
    var wordCount: Int?             //字数
    var content: String?            //内容
    var createTime: Int?            //创建时间
    var updateTime: Int?            //更新时间
    
    override init() {
        
    }
    
    init(name: String?, href: String?, wordCount: Int?) {
        self.name = name
        self.href = href
        self.wordCount = wordCount
    }
    
    override public func setJSONValues(_ values: [String : Any]) {
        self.id         = getJSONValue(named: "id", from: values, defaultValue: "")
        self.bookID     = getJSONValue(named: "bookID", from: values, defaultValue: "")
        self.name       = getJSONValue(named: "name", from: values, defaultValue: "")
        self.href       = getJSONValue(named: "href", from: values, defaultValue: "")
        self.wordCount  = getJSONValue(named: "wordCount", from: values, defaultValue: 0)
        self.content    = getJSONValue(named: "content", from: values, defaultValue: "")
        self.createTime = getJSONValue(named: "createTime", from: values, defaultValue: 0)
        self.updateTime = getJSONValue(named: "updateTime", from: values, defaultValue: 0)
    }
    
    override public func getJSONValues() -> [String : Any] {
        return [
            "id":id ?? "",
            "bookID":bookID ?? "",
            "name":name ?? "",
            "href":href ?? "",
            "wordCount":wordCount ?? 0,
            "content":content ?? "",
            "createTime":createTime ?? 0,
            "updateTime":updateTime ?? 0,
        ]
    }

    public func description() {
        print("章节名:\(self.name ?? "null") 地址:\(self.href ?? "null") 字数:\(self.wordCount ?? 0)")
    }
}
