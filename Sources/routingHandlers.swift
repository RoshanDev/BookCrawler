//
//  routingHandlers.swift
//  BookCrawler
//
//  Created by Roshan on 2016/12/11.
//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import MongoDB

func addURLRoutes() {
    routes.add(uri: "/test", handler: testHandler)
    routes.add(uri: "/mongo", handler: mongoHandler)
}

// 将所有路由都注册到服务器上。
public func PerfectServerModuleInit() {
    addURLRoutes()
}

func testHandler(request: HTTPRequest, _ response: HTTPResponse) {
    let returning = "{你好，世界！}"
    response.appendBody(string: returning)
    response.completed()
}

func mongoHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    // 创建连接
    let client = try! MongoClient(uri: "mongodb://roshan:fh920913@ds129018.mlab.com:29018")
    
    // 连接到具体的数据库，假设有个数据库名字叫 test
    let db = client.getDatabase(name: "rosbookworm")
    
    // 定义集合
    guard let collection = db.getCollection(name: "bookworm") else {
        return
    }
    
    // 在关闭连接时注意关闭顺序与启动顺序相反
    defer {
        collection.close()
        db.close()
        client.close()
    }
    
    // 执行查询
    let fnd = collection.find(query: BSON())
    
    // 初始化一个空数组用于存放结果记录集
    var arr = [String]()
    
    // "fnd" 游标是一个 MongoCursor 类型，用于遍历结果
    for x in fnd! {
        arr.append(x.asString)
    }
    
    // 返回一个格式化的 JSON 数组。
    let returning = "{\"data\":[\(arr.joined(separator: ","))]}"
    
    // 返回 JSON 字符串
    response.appendBody(string: returning)
    response.completed()
}

