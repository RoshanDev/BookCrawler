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
    
    routes.add(uri: "/mongoInsert", handler: mongoInsertHandler)
    routes.add(uri: "/mongoUpdate", handler: mongoUpdateHandler)
    routes.add(uri: "/mongoInsertOrUpdate", handler: mongoInsertOrUpdateHandler)
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


func mongoInsertHandler(request: HTTPRequest, _ response: HTTPResponse) {
    let collection = ROSMongoDBManager.manager.testCollection!
    let bson = BSON()
    bson.append(key: "name", string: "Roshan")
    bson.append(key: "age", int: 25)
    _ = collection.insert(document: bson)
    response.appendBody(string: "123")
    response.completed()
}


func mongoUpdateHandler(request: HTTPRequest, _ response: HTTPResponse) {
    let collection = ROSMongoDBManager.manager.testCollection!
    let bson = BSON()
    bson.append(key: "name", string: "Roshan")
    
    let mutBson = BSON()
    mutBson.append(key: "name", string: "Roshan")
    mutBson.append(key: "age", int: 26)
    
    let result:MongoResult = collection.update(selector: bson, update: mutBson)
    print("mongoUpdate\(result)")

    response.appendBody(string: "234")
    response.completed()
}

func mongoInsertOrUpdateHandler(request: HTTPRequest, _ response: HTTPResponse) {
    let collection = ROSMongoDBManager.manager.testCollection!
    let bson = BSON()
    bson.append(key: "name", string: "Roshan")
//    bson.append(key: "age", string: "57")

    let mutBson = BSON()
    mutBson.append(key: "name", string: "Roshan")
    mutBson.append(key: "age", int: 25)
    
    let result:MongoResult = collection.findAndModify(query: bson, sort: nil, update: mutBson, fields: nil, remove: false, upsert: false, new: false)
    //没有查到的时候 mongoInsertOrUpdatereplyDoc({ "lastErrorObject" : { "updatedExisting" : false, "n" : 0 }, "value" : null, "ok" : 1 })
    //查到的时候 mongoInsertOrUpdatereplyDoc({ "lastErrorObject" : { "updatedExisting" : true, "n" : 1 }, "value" : { "_id" : { "$oid" : "584e8aa4c990d82af6690771" }, "name" : "Roshan", "age" : 30 }, "ok" : 1 })

    print("mongoInsertOrUpdate\(result)")
    
    response.appendBody(string: "345")
    response.completed()
}

func mongoHandler(request: HTTPRequest, _ response: HTTPResponse) {
    
    let collection = ROSMongoDBManager.manager.testCollection!
    
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

