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
    static let client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018/rosbookworm")

    static func crawSumClickList() -> Dictionary<String, Any> {
        
        let crawUri = "http://www.quanshu.net/all/allvisit_1_0_0_0_0_0_1.html"
        guard let crawUrl = URL(string: crawUri) else {
            let message = "Error: \(crawUri) doesn't seem to be a valid URL"
            return CrawLib.showResponse(code: 0, message: message, data: nil)
        }
        
        do {
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))

            let myHTMLString = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
            //let htmlDic =
            _ = CrawLib.crawClickList(html: myHTMLString)
            return ["1":1, "2":2]
        } catch let error {
            print("Error: \(error)")
            return CrawLib.showResponse(code: 0, message: error.localizedDescription, data: nil)
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
    
    static func detailInfo() -> Dictionary<String, Any> {
        
        let crawUri = "http://www.quanshu.net/book_1412.html"
        guard let crawUrl = URL(string: crawUri) else {
            let message = "Error: \(crawUri) doesn't seem to be a valid URL"
            return CrawLib.showResponse(code: 0, message: message, data: nil)
        }
        
        do {
            let cfEnc = CFStringEncodings.GB_18030_2000
            let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
            
            let myHTMLString = try String(contentsOf: crawUrl, encoding: String.Encoding(rawValue: enc))
            CrawLib.crawBookInfo(html: myHTMLString)
            return ["1":1, "2":2]
        } catch let error {
            print("Error: \(error)")
            return CrawLib.showResponse(code: 0, message: error.localizedDescription, data: nil)
        }
    }

    
    static func crawBookInfo(html: String) {
        guard let collection: MongoCollection = ROSMongoDBManager.manager.bookinfoCollection else {
            return
        }
        
        let queryBson = BSON()
        queryBson.append(key: "name", string: "绝世唐门")
        let fnd = collection.find(query: queryBson)
        
        if let bookEle = fnd?.next() {
            print(bookEle)
            let bookStr = bookEle.asString
            if let dataFromString = bookStr.data(using: .utf8, allowLossyConversion: false) {
                let bookJson = JSON(data: dataFromString)
                print(bookJson["name"])
            }
        }
    }
    
    static func crawClickList(html: String)-> Dictionary<String, Any> {
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
                let book: Book = Book(name: titleElement?.text, author: author, img: imgElement?["src"], href: href)
//                book.description()
                books.append(book)
            }
            
            ROSMongoDBManager.manager.insertBookinfoArray(bookinfos: books)
            let title = doc.title
            let head = doc.head?.innerHTML
            let body = doc.body?.innerHTML
            
            let dic = ["title":title, "head":head, "body":body]
            return dic;
        }
        return ["htmlParse":"failed"]
    }
    
    
    
    func UTF8ToGB2312(str: String) -> (NSData?, UInt) {
       let enc = CFStringConvertEncodingToNSStringEncoding(UInt32(CFStringEncodings.GB_18030_2000.rawValue))
       let data = str.data(using: String.Encoding(rawValue: enc), allowLossyConversion: false)
       return (data as NSData?, enc)
    }

    
}
