//
//  Book.swift
//  AdorableServer
//
//  Created by roshan on 2016/12/9.
//
//

import Foundation
import PerfectLib

public class Book: JSONConvertibleObject {
    var id: String?                 //书籍在mongodb中的oid
    var name: String?               //书名
    var author: String?             //作者
    var img: String?                //封面图
    var href: String?               //详情页链接
    var status: Int?                //0 连载， 1 完本
    var info: String?               //简介
    var clickCount: Int?            //点击量。注意，前期直接将网站上数据覆盖到数据库。后期需要判断本地的是否小于当前值，小于才更新
    var chaptersHref: String?       //章节列表页链接
    var latestUpdateInfo: String?   //最近更新内容
    var latestUpdateDate: Int?   //最近更新时间
    
    override init() {
        
    }
    
    init(id: String? = nil, name: String, author: String, img: String? = nil, href: String = "", status: Int? = 0, info: String? = nil, clickCount: Int? = 0, chaptersHref: String? = nil, latestUpdateInfo: String? = nil, latestUpdateDate: Int? = 0) {
        self.id = id
        self.name = name
        self.author = author
        self.img = img
        self.href = href
        self.status = status
        self.info = info
        self.clickCount = clickCount
        self.chaptersHref = chaptersHref
        self.latestUpdateInfo = latestUpdateInfo
        self.latestUpdateDate = latestUpdateDate
    }
    
    override public func setJSONValues(_ values: [String : Any]) {
        self.id                 = getJSONValue(named: "id", from: values, defaultValue: "")
        self.name               = getJSONValue(named: "name", from: values, defaultValue: "")
        self.author             = getJSONValue(named: "author", from: values, defaultValue: "")
        self.img                = getJSONValue(named: "img", from: values, defaultValue: "")
        self.href               = getJSONValue(named: "href", from: values, defaultValue: "")
        self.status             = getJSONValue(named: "status", from: values, defaultValue: 0)
        self.info               = getJSONValue(named: "info", from: values, defaultValue: "")
        self.clickCount         = getJSONValue(named: "clickCount", from: values, defaultValue: 0)
        self.chaptersHref       = getJSONValue(named: "chaptersHref", from: values, defaultValue: "")
        self.latestUpdateInfo   = getJSONValue(named: "latestUpdateInfo", from: values, defaultValue: "")
        self.latestUpdateDate   = getJSONValue(named: "latestUpdateDate", from: values, defaultValue: 0)
    }
    
    override public func getJSONValues() -> [String : Any] {
        return [
            "id":id ?? "",
            "name":name ?? "",
            "author":author ?? "",
            "img":img ?? "",
            "href":href ?? "",
            "status":status ?? 0,
            "info":info ?? "",
            "clickCount":clickCount ?? 0,
            "chaptersHref":chaptersHref ?? "",
            "latestUpdateInfo":latestUpdateInfo ?? "",
            "latestUpdateDate":latestUpdateDate ?? 0,
        ]
    }

    
    public func description() {
        print(self.jsonEncodedString())
        print("书名:《\(self.name ?? "null")》 作者:\(self.author ?? "null") 链接:\(self.href ?? "null")")
    }
}
