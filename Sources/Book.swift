//
//  Book.swift
//  AdorableServer
//
//  Created by roshan on 2016/12/9.
//
//

import Foundation

public class Book {
    var name: String?
    var author: String?
    var img: String?
    var href: String?
    init(name: String?, author: String?, img: String?, href: String?) {
        self.name = name
        self.author = author
        self.img = img
        self.href = href
    }
    public func description() {
        print("书名:《\(self.name ?? "null")》 作者:\(self.author ?? "null") 封面:\(self.img ?? "null") 链接:\(self.href ?? "null")")
    }
}
