//
//  CrawLib.swift
//  AdorableServer
//
//  Created by roshan on 2016/12/9.
//
//

import PerfectLib
import PerfectHTTP
import Foundation
import Kanna
import MongoDB
import SwiftyJSON

public class CrawLib {
//    static let client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018/rosbookworm")
    
    static func startCrawBookInfo() {
//        let lastListIndex = 1
//        let lastBookIndex = 0
//        let startListIndex = 1
        
        
        
    }
    
    //点击列表页路由事件
    static func crawSumClickList(listIndex: Int = 1) -> Dictionary<String, Any> {
        
        let crawUri = "http://www.quanshu.net/all/allvisit_0_0_0_0_0_0_" + String(listIndex) + ".html"
        guard let crawUrl = URL(string: crawUri) else {
            let message = "Error: \(crawUri) doesn't seem to be a valid URL"
            return CrawLib.showResponse(code: 0, message: message, data: nil)
        }
        
        do {
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))

            let myHTMLString = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
            //let htmlDic =
            let books = CrawLib.crawClickList(html: myHTMLString)
            
            // TODO: 开启多线程，现在太慢了
            for book in books {
                CrawLib.crawBookInfo(href: book.href!)
            }
            
            // TODO: 需要存储下来已更新的页面index
            print("第\(listIndex)页数据抓取完毕")
            if listIndex > 2541 {
                return ["completed":1]
            }else {
                _ = CrawLib.crawSumClickList(listIndex: (listIndex + 1))
                return ["completed":0]
            }
        } catch let error {
            print("Error: \(error)")
            // TODO: 需要存储下来已更新的页面index，并写入失败队列
            return CrawLib.showResponse(code: 0, message: error.localizedDescription, data: nil)
        }
    }
    
    //详情页路由事件
    static func detailInfo() -> Dictionary<String, Any> {
        
        let crawUri = "http://www.quanshu.net/book_13720.html"
        guard let crawUrl = URL(string: crawUri) else {
            let message = "Error: \(crawUri) doesn't seem to be a valid URL"
            return CrawLib.showResponse(code: 0, message: message, data: nil)
        }
        
        do {
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            
            let myHTMLString = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
//            CrawLib.crawBookInfo(href: crawUri, html: myHTMLString)
            return ["1":1, "2":2]
        } catch let error {
            // FIXME: 需要存到失败队列中
            print("Error: \(error)")
            
            return CrawLib.showResponse(code: 0, message: error.localizedDescription, data: nil)
        }
    }

    //章节列表页路由事件
    static func chaptersInfo() -> Dictionary<String, Any> {
        let book = Book(name: "绝世唐门", author: "唐家三少", img: "http://img.quanshu.net/image/13/13720/13720s.jpg", href: "http://www.quanshu.net/book_13720.html")
        book.chaptersHref = "http://www.quanshu.net/book/13/13720/"

        CrawLib.crawBookChaptersInfo(bookInfo: book)
        return ["1":1, "2":2]

    }
    
    //章节详情页路由事件
    static func chapterDetailInfo() -> Dictionary<String, Any> {
        let book = Book(name: "绝世唐门", author: "唐家三少", img: "http://img.quanshu.net/image/13/13720/13720s.jpg", href: "http://www.quanshu.net/book_13720.html")
        book.chaptersHref = "http://www.quanshu.net/book/13/13720"
        
        let chapter = Chapter(name: "第六百一十九章 第三魂核！（上）", href: "13927343.html", wordCount: 3711)
        chapter.createTime = 1481525611
        CrawLib.crawChapterDetailInfo(book: book, chapter: chapter)
        return ["1":1, "2":2]
    }
    
    
    static func crawClickList(html: String)-> [Book] {
        if let doc = HTML(html: html, encoding: .utf8) {
            let listElement = doc.at_xpath("//*[@id=\"wrapper\"]/div[3]/div/div/div/div[2]/div[2]/div")
            
            var books = [Book]()
            
            for bookElement in (listElement?.xpath("div"))! {
                print(bookElement.innerHTML ?? "bookElement.innerHTML nil")
                
                let aElement = bookElement.at_xpath("a")
                let href = aElement?["href"]
                //不能用"//a/h2"，奇怪，为啥
                //let titleElement = bookElement.at_xpath("a/h2")
                let titleElement = aElement?.at_xpath("h2")
                let authorElement = bookElement.at_xpath("div/dl/dd/p")
                let imgElement = aElement?.at_xpath("img[@alt]")
                var author = authorElement?.text;
                author = author?.replacingOccurrences(of: "作者：", with: "")
                let book: Book = Book(name: (titleElement?.text)!, author: author!, img: imgElement?["src"], href: href!)
                books.append(book)
            }
//            ROSMongoDBManager.manager.insertBookinfoArray(bookinfos: books)
            return books
        }
        return [Book]()
    }
    
    //爬取书籍详情页数据，如果有数据，则更新数据；若没有，则插入新数据 
    static func crawBookInfo(href: String) {
        
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        
        guard let crawUrl = URL(string: href) else {
            let message = "Error: \(href) doesn't seem to be a valid URL"
            print(message)
            return
        }
        
        do {
            let myHTMLString = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
            
            let doc = HTML(html: myHTMLString, encoding: .utf8)
            if doc == nil {
                return
            }
            
            let titleXpath = "//*[@id=\"container\"]/div[2]/section/div/div[1]/h1"
            
            let titleElement = doc!.at_xpath(titleXpath)
            let title = titleElement?.text
            
            if title == nil {
                return
            }
            
            let authorXpath = "//*[@id=\"container\"]/div[2]/section/div/div[4]/div[1]/dl[3]/dd/a"
            let authorElement = doc!.at_xpath(authorXpath)
            let author = authorElement?.text
            
            let imgXpath = "//*[@id=\"container\"]/div[2]/section/div/a/img"
            let imgElement = doc!.at_xpath(imgXpath)
            let img = imgElement?["src"]
            
            // FIXME: book status 数据不对
            let statusXpath = "//*[@id=\"container\"]/div[2]/section/div/div[4]/div[1]/dl[1]/dd"
            let statusElement = doc!.at_xpath(statusXpath)
            let status = statusElement?.text
            var statusCode = 0
            if status! == "完本" {
                statusCode = 1
            }
            
            let clickCountXpath = "//*[@id=\"container\"]/div[2]/section/div/div[4]/div[1]/dl[2]/dd"
            let clickCountElement = doc!.at_xpath(clickCountXpath)
            let clickCountStr = clickCountElement?.text
            let clickCount = Int(clickCountStr!)
            
            
            // FIXME: 删除"介绍:    "字样
            let infoXpath = "//*[@id=\"waa\"]"
            let infoElement = doc!.at_xpath(infoXpath)
            let info = infoElement?.text
            
            let chaptersHrefXpath = "//*[@id=\"container\"]/div[2]/section/div/div[1]/div[2]/a[1]"
            let chaptersHrefElement = doc!.at_xpath(chaptersHrefXpath)
            let chaptersHref = chaptersHrefElement?["href"]
            
            let latestUpdateXpath = "//*[@id=\"container\"]/div[2]/section/div/div[4]/div[1]/dl[5]/dd/ul/li[1]"
            let latestUpdateElement = doc!.at_xpath(latestUpdateXpath)
            let latestUpdateInfo = latestUpdateElement?.at_xpath("a")?.text
            
            
            var latestUpdateDate = latestUpdateElement?.text
            if latestUpdateInfo != nil {
                latestUpdateDate = latestUpdateDate?.replacingOccurrences(of: latestUpdateInfo!, with: "")
            }
            
            let book: Book = Book(name: title!, author: author!, img: img, href: href, status: statusCode, info: info, clickCount: clickCount!, chaptersHref: chaptersHref, latestUpdateInfo: latestUpdateInfo, latestUpdateDate: latestUpdateDate)
            
            let result = ROSMongoDBManager.manager.insertOrUpdateBookinfo(bookinfo: book)
            
            if result {
                print("更新书籍《\(title!)》数据成功")
            }else {
                print("更新书籍《\(title!)》数据失败")
            }
            
            /*
             //是否需要这样先判断是否有info字段，没有再更新？
             guard let collection: MongoCollection = ROSMongoDBManager.manager.bookinfoCollection else {
             return
             }
             let queryBson = BSON()
             queryBson.append(key: "name", string: title!)
             let fnd = collection.find(query: queryBson)
             
             if let bookEle = fnd?.next() {
             print(bookEle)
             let bookStr = bookEle.asString
             if let dataFromString = bookStr.data(using: .utf8, allowLossyConversion: false) {
             let bookJson = JSON(data: dataFromString)
             
             let latestUpdate = bookJson["latestUpdate"]
             if latestUpdate == nil {
             //此处更新
             }
             }
             }*/
        } catch let error{
            print("获取链接\(href)的书籍详情数据失败")
            print("Error: \(error)")
        }
    }

    //爬取书籍目录信息
    static func crawBookChaptersInfo(bookInfo: Book) {
        
        guard let crawUrl = URL(string: bookInfo.chaptersHref!) else {
            let message = "Error: \(bookInfo.chaptersHref!) doesn't seem to be a valid URL"
            print(message)
            return
        }
        
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        
        do {
            let html = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
            let doc = HTML(html: html, encoding: .utf8)
            if doc == nil {
                return
            }
            
            //先取出卷信息
            let volumeXpath = "//div[@class='clearfix dirconone']"
            //接着取出章节信息
            var chapters = [Chapter]()
            for volumeElement in (doc?.xpath(volumeXpath))! {
                // /div/li/a解析不出来
                let chapterXpath = "li/a"
                for chapterElement in volumeElement.xpath(chapterXpath) {
                    let chapterName = chapterElement.text
                    let href = chapterElement["href"]
                    
                    var tempStr = chapterElement["title"]
                    let tempArr = tempStr?.components(separatedBy: "，")
                    tempStr = tempArr?.last?.replacingOccurrences(of: "共", with: "").replacingOccurrences(of: "字", with: "")
                    let wordCount = Int(tempStr!)
                    let chapter = Chapter.init(name: chapterName, href: href, wordCount: wordCount)
                    chapter.createTime = CrawLib.timeStamp()
                    chapter.description()
                    
                    chapters.append(chapter)
                }
            }
            
            ROSMongoDBManager.manager.insertBookChapters(book: bookInfo, chapters: chapters)

        } catch {
            
        }
    }
    
    //爬取章节详情信息
    static func crawChapterDetailInfo(book: Book, chapter: Chapter) {
        let crawUri = book.chaptersHref! + "/" + chapter.href!
        
        guard let crawUrl = URL(string: crawUri) else {
            let message = "Error: \(crawUri) doesn't seem to be a valid URL"
            print(message)
            return
        }
        
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        
        do {
            let html = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
            let doc = HTML(html: html, encoding: .utf8)
            if doc == nil {
                return
            }
            
            let contentXpath = "//*[@id=\"content\"]"
            let contentElement = doc?.at_xpath(contentXpath)
            
            var tempContent = contentElement?.text
            
            let tempXpath = "script"
            
            for tempElement in (contentElement?.xpath(tempXpath))! {
                tempContent = tempContent?.replacingOccurrences(of: tempElement.text!, with: "")
            }
            
            chapter.content = tempContent
            chapter.updateTime = CrawLib.timeStamp()
            
            let result = ROSMongoDBManager.manager.insertOrUpdateChapterInfo(chapter: chapter)
            if result {
                print("更新章节《\(chapter.name!)》数据成功")
            }else {
                print("更新章节《\(chapter.name!)》数据失败")
            }
        } catch {
            
        }
    }
    
    static func showResponse(code: Int, message: String, data: Dictionary<String, Any>?)-> Dictionary<String, Any>{
        var response: Dictionary<String, Any>
        
        if (data != nil) {
            response = ["code":code, "message":message, "data":data!] as [String : Any]
        }else {
            response = ["code":code, "message":message] as [String : Any]
        }
        return response
    }

    static func timeStamp() -> Int {
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        return Int(timeInterval)
    }
    
    func UTF8ToGB2312(str: String) -> (NSData?, UInt) {
       let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
       let data = str.data(using: String.Encoding(rawValue: enc), allowLossyConversion: false)
       return (data as NSData?, enc)
    }
}
