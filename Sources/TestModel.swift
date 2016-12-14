//
//  TestModel.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/14.
//
//

import Foundation
import PerfectLib

class ATestModel: JSONConvertibleObject {
    
    var str1: String
    var str2: String
    var str3: String
    var str4: String
    var str5: String?
    var str6: String?
    var str7: String?
    var str8: String?
    var str9: String?
    
    var int1: Int?
    var int2: Int?
    var int3: Int?

    
    init(str1:String = "", str2:String = "", str3:String = "", str4:String = "") {
        self.str1 = str1
        self.str2 = str2
        self.str3 = str3
        self.str4 = str4
    }
    
//    override public func setJSONValues(_ values: [String : Any]) {
//        
//    }
    
//    override public func getJSONValues() -> [String : Any] {
//        return [
//            "str1":str1,
//            "str2":str2,
//            "str3":str3,
//            "str4":str4,
//            "str5":str5 ?? "",
//            "str6":str6 ?? "",
//            "str7":str7 ?? "",
//            "str8":str8 ?? "",
//            "str9":str9 ?? "",
//            "int1":int1 ?? 0
//        ]
//    }
}
