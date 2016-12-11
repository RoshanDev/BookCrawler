//
//  ROSMongoDBManager.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/11.
//
//

import Foundation
import MongoDB

class ROSMongoDBManager {
    private(set) var client:MongoClient
    private(set) var db: MongoDatabase
    private(set) var bookinfoCollection: MongoCollection?
    static let manager = ROSMongoDBManager()
    
    init() {
        self.client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018/rosbookworm")
        self.db = client.getDatabase(name: "rosbookworm")
        self.bookinfoCollection = db.getCollection(name: "bookinfo")
    }
    
    deinit {
        print("release mongo collection, db, client")
        self.bookinfoCollection?.close()
        self.db.close()
        self.client.close()
    }
    
    func insertBookinfoArray(bookinfos: Array<Book>) {
        var books = [BSON]()

        for abook in bookinfos {
            books.append(self.convertBookToBSON(book: abook))
        }
        //                _ = collection?.insert(document: bookBSON)
        let result = (ROSMongoDBManager.manager.bookinfoCollection?.insert(documents: books))
        print(result ?? "insertOrUpdateBookinfoArray nil")
    }
    
    func insertOrUpdateBookinfo(book: Book) -> Bool {
        let queryBSON = BSON()
        queryBSON.append(key: "name", string: book.name ?? "")
        queryBSON.append(key: "author", string: book.author ?? "")
        let updateBSON = self.convertBookToBSON(book: book)
        let result: MongoResult = (ROSMongoDBManager.manager.bookinfoCollection?.findAndModify(query: queryBSON, sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
        
        switch result {
        case MongoResult.success:
            return true
        default:
            return false
        }
    }
    
    func convertBookToBSON(book: Book) -> BSON {
        let bookBSON = BSON()
        
        bookBSON.append(key: "name", string: book.name ?? "")
        bookBSON.append(key: "author", string: book.author ?? "")
        bookBSON.append(key: "img", string: book.img ?? "")
        bookBSON.append(key: "href", string: book.href ?? "")
        bookBSON.append(key: "author", string: book.author ?? "")
        return bookBSON
    }
}
