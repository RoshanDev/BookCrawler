//
//  ROSMongoDBManager.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/11.
//
//

import Foundation
import MongoDB
import SwiftyJSON

class ROSMongoDBManager {
    private(set) var client:MongoClient
    private(set) var db: MongoDatabase
    //如果该集合不存在于mongodb中，但是后来使用了insert相关函数，会自动新建该集合，然后执行相关操作
    private(set) var bookinfoCollection: MongoCollection?
    private(set) var chapterCollection: MongoCollection?
    private(set) var testCollection: MongoCollection?
    
    static let manager = ROSMongoDBManager()
    
    init() {
        self.client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018/rosbookworm")
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
            books.append(self.convertBookToBSON(book: abook))
        }
        let result = (ROSMongoDBManager.manager.bookinfoCollection?.insert(documents: books))
        print(result ?? "insertBookinfoArray nil")
    }
    
    func fetchBookFromMongoDB(book: Book) -> Book? {
        let fnd = ROSMongoDBManager.manager.bookinfoCollection?.find(query: self.bookQueryBSON(book: book))
        if let bookBson = fnd?.next() {
            print(bookBson)
            let bookfinded = self.converBSONToBook(bookBSON: bookBson)
            return bookfinded
        }
        return nil
//        let result: MongoResult = (ROSMongoDBManager.manager.bookinfoCollection?.findAndModify(query: self.bookQueryBSON(book: book), sort: nil, update: nil, fields: nil, remove: false, upsert: false, new: false))!;
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
        let result: MongoResult = (ROSMongoDBManager.manager.bookinfoCollection?.update(selector: queryBSON, update: self.convertBookToBSON(book: book)))!
        switch result {
        case MongoResult.error:
            return false
        default:
            return true
        }
    }
    
    //插入或更新书籍信息
    func insertOrUpdateBookinfo(bookinfo: Book) -> Bool {
        let updateBSON = self.convertBookToBSON(book: bookinfo)
        //如果该书籍在bookinfo集合中不存在，则插入该书籍
        let result: MongoResult = (ROSMongoDBManager.manager.bookinfoCollection?.findAndModify(query: self.bookQueryBSON(book: bookinfo), sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
        
        switch result {
        case MongoResult.error:
            return false
        default:
            return true
        }
    }
    
    //插入书籍章节列表信息
    func insertBookChapters(book: Book, chapters: Array<Chapter>) {
        let removeBSON = self.bookQueryBSON(book: book)
        let collection = ROSMongoDBManager.manager.chapterCollection
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
    func insertOrUpdateChapterInfo(chapter: Chapter) -> Bool {
        
        let queryBSON = self.chapterQueryBSON(chapter: chapter)
        let updateBSON = self.convertChapterToBSON(chapter: chapter)
        let result: MongoResult = (ROSMongoDBManager.manager.chapterCollection?.findAndModify(query: queryBSON, sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
        
        switch result {
        case MongoResult.error:
            return false
        default:
            return true
        }
    }

    
    /// 获取 Book 对象的 MongoDB 查询 BSON
    ///
    /// - Parameter book: Book 对象
    /// - Returns: MongoDB 查询 BSON
    func bookQueryBSON(book: Book) -> BSON {
        //此处默认小说标题是唯一字段。以后如果多站抓取的话需要加上站点信息。
        let queryBSON = BSON()
        queryBSON.append(key: "name", string: book.name!)
        if let author = book.author {
            queryBSON.append(key: "author", string: author)
        }
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
            let bookJson = JSON(data: dataFromString)
            
            book.name = bookJson["name"].string
            book.author = bookJson["author"].string
            book.img = bookJson["img"].string
            book.href = bookJson["href"].string
            book.status = bookJson["status"].int
            book.info = bookJson["info"].string
            book.clickCount = bookJson["clickCount"].int
            book.chaptersHref = bookJson["chaptersHref"].string
            book.latestUpdateInfo = bookJson["latestUpdateInfo"].string
            book.latestUpdateDate = bookJson["latestUpdateDate"].string
        }
        return book
    }
    
    /// 将 Book 对象转换成 BSON 数据
    ///
    /// - Parameter book: Book 对象
    /// - Returns: BSON 数据
    func convertBookToBSON(book: Book) -> BSON {
        let bookBSON = BSON()
        
        /*
         var name: String?               //书名
         var author: String?             //作者
         var img: String?                //封面图
         var href: String?               //详情页链接
         var status: Int?                //0 连载， 1 完本
         var info: String?               //简介
         var clickCount: Int?            //点击量。注意，前期直接将网站上数据覆盖到数据库。后期需要判断本地的是否小于当前值，小于才更新
         var chaptersHref: String?       //章节列表页链接
         var latestUpdateInfo: String?   //最近更新内容
         var latestUpdateDate: String?   //最近更新时间
         */
        bookBSON.append(key: "name", string: book.name ?? "")
        bookBSON.append(key: "author", string: book.author ?? "")
        bookBSON.append(key: "img", string: book.img ?? "")
        bookBSON.append(key: "href", string: book.href ?? "")
        bookBSON.append(key: "status", int: book.status ?? 0)
        bookBSON.append(key: "info", string: book.info ?? "")
        bookBSON.append(key: "clickCount", int: book.clickCount ?? 0)
        bookBSON.append(key: "chaptersHref", string: book.chaptersHref ?? "")
        bookBSON.append(key: "latestUpdateInfo", string: book.latestUpdateInfo ?? "")
        bookBSON.append(key: "latestUpdateDate", string: book.latestUpdateDate ?? "")
        return bookBSON
    }
    
    /// 将 Chapter 对象转换成 BSON 数据
    ///
    /// - Parameter chapter: Chapter 对象
    /// - Returns: BSON 数据
    func convertChapterToBSON(chapter: Chapter) -> BSON {
        let chapterBSON = BSON()
        /*
         var name: String?
         var href: String?
         var wordCount: Int?
         
         var content: String?
         var createTime: Int?
         var updateTime: Int?

         */
        chapterBSON.append(key: "name", string: chapter.name ?? "")
        chapterBSON.append(key: "href", string: chapter.href ?? "")
        chapterBSON.append(key: "wordCount", int: chapter.wordCount ?? 0)
        chapterBSON.append(key: "content", string: chapter.content ?? "")
        chapterBSON.append(key: "createTime", int: chapter.createTime ?? 0)
        chapterBSON.append(key: "updateTime", int: chapter.updateTime ?? 0)
        
        return chapterBSON
    }
    
}
