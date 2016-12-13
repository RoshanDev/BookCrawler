//
//  Book.swift
//  AdorableServer
//
//  Created by roshan on 2016/12/9.
//
//

import Foundation

public class Book {
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
    
    init() {
        
    }
    
    init(name: String, author: String, img: String? = nil, href: String = "", status: Int? = 0, info: String? = nil, clickCount: Int? = 0, chaptersHref: String? = nil, latestUpdateInfo: String? = nil, latestUpdateDate: Int? = 0) {
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
    
    public func description() {
        print("书名:《\(self.name ?? "null")》 作者:\(self.author ?? "null") 链接:\(self.href ?? "null")")
    }
}
