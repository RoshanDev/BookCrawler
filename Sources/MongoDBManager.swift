//
//  MongoDBManager.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/11.
//
//

import Foundation
import MongoDB
//import SwiftyJSON
//import Genome

class MongoDBManager {
    private(set) var client:MongoClient
    private(set) var db: MongoDatabase
    //如果该集合不存在于mongodb中，但是后来使用了insert相关函数，会自动新建该集合，然后执行相关操作
    private(set) var bookinfoCollection: MongoCollection?
    private(set) var chapterCollection: MongoCollection?
    private(set) var testCollection: MongoCollection?
    
    static let manager = MongoDBManager()
    
    init() {
//        self.client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018/rosbookworm")
        self.client = try! MongoClient(uri: "mongodb://localhost:27017/rosbookworm")
        self.db = client.getDatabase(name: "rosbookworm")
        self.bookinfoCollection = db.getCollection(name: "bookinfo")
        self.chapterCollection = db.getCollection(name: "bookchapter")
        self.testCollection = db.getCollection(name: "testCollection")//self.getTestCollection()
    }
    
    deinit {
        print("release mongo collection, db, client")
        self.bookinfoCollection?.close()
        self.chapterCollection?.close()
        self.db.close()
        self.client.close()
    }
    
    //将书籍数组保存到mongodb中
    func insertBookinfoArray(bookinfos: Array<Book>) {
        var books = [BSON]()
        for abook in bookinfos {
            if let bookBson = self.convertBookToBSON(book: abook) {
                books.append(bookBson)
            }
        }
        let result = (MongoDBManager.manager.bookinfoCollection?.insert(documents: books))
        print(result ?? "insertBookinfoArray nil")
    }
    
    func fetchBookFromMongoDB(book: Book) -> Book? {
        let fnd = MongoDBManager.manager.bookinfoCollection?.find(query: self.bookQueryBSON(book: book))
        if let bookBson = fnd?.next() {
            print(bookBson)
            let bookfinded = self.converBSONToBook(bookBSON: bookBson)
            return bookfinded
        }
        return nil
//        let result: MongoResult = (MongoDBManager.manager.bookinfoCollection?.findAndModify(query: self.bookQueryBSON(book: book), sort: nil, update: nil, fields: nil, remove: false, upsert: false, new: false))!;
//        switch result {
//        case .replyDoc:
//            
//            let book = Book()
//            return book
//        default:
//            return nil
//
//        }
    }
    
    //更新书籍信息
    func updateBookinfo(book: Book) -> Bool {
        let queryBSON = self.bookQueryBSON(book: book)
        
        if let updateBSON = self.convertBookToBSON(book: book) {
            let result: MongoResult = (MongoDBManager.manager.bookinfoCollection?.update(selector: queryBSON, update: updateBSON))!
            switch result {
            case MongoResult.error:
                return false
            default:
                return true
            }
        }
        
        return false
    }
    
    /// 插入或更新书籍信息
    ///
    /// - Parameter bookinfo: Book 对象
    /// - Returns: mongodb 中的 book ID
    func insertOrUpdateBookinfo(bookinfo: Book) -> String? {
        if let updateBSON = self.convertBookToBSON(book: bookinfo) {
            //如果该书籍在bookinfo集合中不存在，则插入该书籍
            let result: MongoResult = (MongoDBManager.manager.bookinfoCollection?.findAndModify(query: self.bookQueryBSON(book: bookinfo), sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
            
            switch result {
            case MongoResult.replyDoc(let bson):
                if let dataFromString = bson.asString.data(using: .utf8, allowLossyConversion: false) {
                    if let bookJson  = try? JSONSerialization.jsonObject(with: dataFromString, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any> {
//                        let bookID = bookJson["value"]?["_id"]?["$oid"]
                        if let bookID = ((bookJson["value"] as? Dictionary<String, Any>)?["_id"] as? Dictionary<String, Any>)?["$oid"] as? String {
//                            print(bookID)
                            return bookID
                        }
                        
                        if let newBookID = ((bookJson["lastErrorObject"] as? Dictionary<String, Any>)?["upserted"] as? Dictionary<String, Any>)?["$oid"] as? String {
                            //                            print(bookID)
                            return newBookID
                        }
                    }
                }
            default:
                break
            }
        }
        return nil
    }
    
    //插入书籍章节列表信息
    func insertBookChapters(book: Book, chapters: Array<Chapter>) {
        let removeBSON = self.bookQueryBSON(book: book)
        let collection = MongoDBManager.manager.chapterCollection
        let result: MongoResult = (collection?.remove(selector: removeBSON))!
        switch result {
        case .success:
            break
        default:
            return
        }
        
        var chapterBSONs = [BSON]()
        for chapter in chapters {
            chapterBSONs.append(self.convertChapterToBSON(chapter: chapter))
        }
        let insertResult = collection?.insert(documents: chapterBSONs)
        print(insertResult ?? "insertBookChapters nil")
    }
    
    //插入或更新章节详情信息
    func insertOrUpdateChapterInfo(chapter: Chapter) -> String? {
        let queryBSON = self.chapterQueryBSON(chapter: chapter)
        let updateBSON = self.convertChapterToBSON(chapter: chapter)
        let result: MongoResult = (MongoDBManager.manager.chapterCollection?.findAndModify(query: queryBSON, sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
        
        switch result {
        case MongoResult.replyDoc(let bson):
            if let dataFromString = bson.asString.data(using: .utf8, allowLossyConversion: false) {
                if let bookJson  = try? JSONSerialization.jsonObject(with: dataFromString, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any> {
                    //                        let bookID = bookJson["value"]?["_id"]?["$oid"]
                    if let chapterID = ((bookJson["value"] as? Dictionary<String, Any>)?["_id"] as? Dictionary<String, Any>)?["$oid"] as? String {
                        //                            print(bookID)
                        return chapterID
                    }
                    
                    if let newChapterID = ((bookJson["lastErrorObject"] as? Dictionary<String, Any>)?["upserted"] as? Dictionary<String, Any>)?["$oid"] as? String {
                        //                            print(bookID)
                        return newChapterID
                    }
                }
            }
        default:
            break
        }
        return nil
    }

    
    /// 获取 Book 对象的 MongoDB 查询 BSON
    ///
    /// - Parameter book: Book 对象
    /// - Returns: MongoDB 查询 BSON
    func bookQueryBSON(book: Book) -> BSON {
        //此处默认小说标题是唯一字段。以后如果多站抓取的话需要加上站点信息。
        let queryBSON = BSON()
        queryBSON.append(key: "name", string: book.name)
        queryBSON.append(key: "author", string: book.author)
        return queryBSON
    }
    
    
    /// 获取 Chapter 对象的 MongoDB 查询 BSON
    ///
    /// - Parameter chapter: Chapter 对象
    /// - Returns: MongoDB 查询 BSON
    func chapterQueryBSON(chapter: Chapter) -> BSON {
        let queryBSON = BSON()
        queryBSON.append(key: "name", string: chapter.name!)
        queryBSON.append(key: "href", string: chapter.href!)
        return queryBSON
    }
    
    
    /// 将 BSON 数组转换成 Book 对象
    ///
    /// - Parameter bookBSON: mongodb 返回的 BSON 数据
    /// - Returns: Book 对象
    func converBSONToBook(bookBSON: BSON) -> Book {
        let book = Book()
        if let dataFromString = bookBSON.asString.data(using: .utf8, allowLossyConversion: false) {
            let bookJson = try? JSONSerialization.jsonObject(with: dataFromString, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
            book.setJSONValues(bookJson!)
        }
        return book
    }
    
    /// 将 Book 对象转换成 BSON? 数据
    ///
    /// - Parameter book: Book 对象
    /// - Returns: BSON? 数据
    func convertBookToBSON(book: Book) -> BSON? {
        let bookJson = try? book.jsonEncodedString()
        if bookJson != nil {
            let bookBSON = try? BSON(json: bookJson!)
            return bookBSON
        }
        return nil
    }
    
    /// 将 Chapter 对象转换成 BSON 数据
    ///
    /// - Parameter chapter: Chapter 对象
    /// - Returns: BSON 数据
    func convertChapterToBSON(chapter: Chapter) -> BSON {
        let chapterBSON = BSON()

        chapterBSON.append(key: "bookID", string: chapter.bookID)
        chapterBSON.append(key: "name", string: chapter.name ?? "")
        chapterBSON.append(key: "href", string: chapter.href ?? "")
        chapterBSON.append(key: "wordCount", int: chapter.wordCount ?? 0)
        chapterBSON.append(key: "content", string: chapter.content ?? "")
        chapterBSON.append(key: "createTime", int: chapter.createTime ?? 0)
        chapterBSON.append(key: "updateTime", int: chapter.updateTime ?? 0)
        
        return chapterBSON
    }
    
}
