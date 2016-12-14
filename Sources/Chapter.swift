//
//  Chapter.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/12.
//
//

import Foundation

public class Chapter {
    var name: String?
    var href: String?
    var wordCount: Int?
    var content: String?
    var createTime: Int?
    var updateTime: Int?
    
    init() {
        
    }
    
    init(name: String?, href: String?, wordCount: Int?) {
        self.name = name
        self.href = href
        self.wordCount = wordCount
    }
    
    public func description() {
        print("章节名:\(self.name ?? "null") 地址:\(self.href ?? "null") 字数:\(self.wordCount ?? 0)")
    }
}
