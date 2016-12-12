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
    private(set) var chapterCollection: MongoCollection?
    
    static let manager = ROSMongoDBManager()
    
    init() {
        self.client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018/rosbookworm")
        self.db = client.getDatabase(name: "rosbookworm")
        self.bookinfoCollection = db.getCollection(name: "bookinfo")
        self.chapterCollection = db.getCollection(name: "bookchapter")
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
    
    //插入或更新书籍信息
    func insertOrUpdateBookinfo(bookinfo: Book) -> Bool {
        //此处默认小说标题是唯一字段。以后如果多站抓取的话需要加上站点信息。
        let queryBSON = BSON()
        queryBSON.append(key: "name", string: bookinfo.name ?? "")
        let updateBSON = self.convertBookToBSON(book: bookinfo)
        let result: MongoResult = (ROSMongoDBManager.manager.bookinfoCollection?.findAndModify(query: queryBSON, sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
        
        switch result {
        case MongoResult.error:
            return false
        default:
            return true
        }
    }
    
    //插入书籍章节列表信息
    func insertBookChapters(name: String, chapters: Array<Chapter>) {
        let removeBSON = BSON()
        removeBSON.append(key: "name", string: name)
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
        let queryBSON = BSON()
        queryBSON.append(key: "href", string: chapter.href ?? "")
        queryBSON.append(key: "name", string: chapter.name ?? "")
        let updateBSON = self.convertChapterToBSON(chapter: chapter)
        let result: MongoResult = (ROSMongoDBManager.manager.chapterCollection?.findAndModify(query: queryBSON, sort: nil, update: updateBSON, fields: nil, remove: false, upsert: true, new: false))!
        
        switch result {
        case MongoResult.error:
            return false
        default:
            return true
        }
    }

    
    //将book对象转换成BSON格式
    func convertBookToBSON(book: Book) -> BSON {
        let bookBSON = BSON()
        
        bookBSON.append(key: "name", string: book.name ?? "")
        bookBSON.append(key: "author", string: book.author ?? "")
        bookBSON.append(key: "img", string: book.img ?? "")
        bookBSON.append(key: "href", string: book.href ?? "")
        bookBSON.append(key: "author", string: book.author ?? "")
        bookBSON.append(key: "info", string: book.info ?? "")
        bookBSON.append(key: "chaptersHref", string: book.chaptersHref ?? "")
        bookBSON.append(key: "latestUpdateInfo", string: book.latestUpdateInfo ?? "")
        bookBSON.append(key: "latestUpdateDate", string: book.latestUpdateDate ?? "")
        return bookBSON
    }
    
    //将chapter对象转换成BSON格式
    func convertChapterToBSON(chapter: Chapter) -> BSON {
        let chapterBSON = BSON()
        
        chapterBSON.append(key: "name", string: chapter.name ?? "")
        chapterBSON.append(key: "href", string: chapter.href ?? "")
        chapterBSON.append(key: "wordCount", int: chapter.wordCount ?? 0)
        chapterBSON.append(key: "content", string: chapter.content ?? "")
        chapterBSON.append(key: "createTime", int: chapter.createTime ?? 0)
        chapterBSON.append(key: "updateTime", int: chapter.updateTime ?? 0)
        
        return chapterBSON
    }
    
}
