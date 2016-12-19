//
//  ProxyManager.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/16.
//
//

import Foundation
import PerfectThread
import PerfectLib
import Dispatch
import PerfectCURL
import cURL
//#include <curl/curl.h>



class ProxyManager {
    
    static let manager = ProxyManager()
    
    var timer: DispatchSourceTimer?
    /// 西刺代理限制的访问时间间隔
    private let xiciAPITimeSpace = 1 //15 minutes
    private let xiciAPIUri = "http://api.xicidaili.com/free2016.txt"
    private var latestFetchTime: Int = 0
    
    /// 有效 IP 数组
    static var validIPs = [String]()
    
    
    /// 未使用 IP 数组
    static var unUsedIPs = [String]()
    
    init() {
//        self.startLoop()
    }
    
    deinit {
        self.stopLoop()
    }
    
    private func startLoop() {
        let duration = xiciAPITimeSpace * 60
//        let timer = Timer(timeInterval: TimeInterval(duration), target: self, selector: #selector(loopFetch), userInfo: nil, repeats: true)
//        timer.fire()
        
        let queue = DispatchQueue(label: "com.scourge.bookCrawler.timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.seconds(Int(duration)))
        timer!.setEventHandler { [weak self] in
            // do whatever you want here
            self?.loopFetch()
        }
        timer!.resume()
    }
    
    func stopLoop() {
        timer?.cancel()
        timer = nil
    }
    
    func runDispatchAfterTimerIfNeeded() {
        
    }
    
    func loopFetch() {
        guard let xiciurl = URL(string: xiciAPIUri) else {
            return
        }
        print("\(xiciurl)");
        self.latestFetchTime = CrawLib.timeStamp()

        guard let iplistStr = try? String(contentsOf: xiciurl, encoding: .utf8) else {
            return
        }
//        iplist = "60.212.33.105:8080\r\n112.86.251.6:8118\r\n178.218.113.2:8080\r\n112.195.73.24:8118\r\n23.88.246.5:8080\r\n52.77.209.182:443\r\n50.93.197.100:1080\r\n49.65.192.170:8998123.139.56.234:9999\r\n113.18.193.12:8000\r\n121.31.157.234:8123\r\n218.66.253.145:8800\r\n123.138.216.94:9999\r\n171.37.156.7:8123\r\n82.209.49.200:8080\r\n115.215.18.82:8998\r\n42.243.21.245:8998\r\n180.117.225.3:8998\r\n114.233.56.252:8998\r\n61.155.233.243:8118\r\n1.195.149.110:8998\r\n123.55.194.43:9999\r\n58.208.116.173:8118\r\n117.95.23.232:8998\r\n114.101.13.91:8998\r\n182.92.112.252:8118\r\n119.101.204.73:8998\r\n105.112.4.194:80\r\n85.15.66.153:8081\r\n125.64.122.246:8998\r\n134.35.117.38:8080\r\n107.0.68.29:3128\r\n36.56.121.198:8118\r\n113.6.137.72:8118\r\n171.38.200.81:8123\r\n27.20.196.129:8998\r\n182.53.4.226:8080\r\n125.88.74.122:83\r\n23.88.246.44:8080\r\n14.211.56.126:9797\r\n169.0.218.215:8080\r\n110.73.0.124:8123\r\n106.88.255.146:8998\r\n222.188.88.10:8998\r\n171.9.41.41:8888\r\n185.22.172.59:3128\r\n60.21.132.218:63000\r\n199.200.61.71:27999\r\n134.35.195.215:8080\r\n203.83.176.28:8080\r\n79.188.42.46:8080\r\n117.65.114.253:8998\r\n1.206.19.45:8998\r\n139.217.5.217:1080\r\n121.193.143.249:80\r\n187.54.93.12:8080\r\n171.38.143.9:8123\r\n110.188.34.91:8118\r\n173.254.197.117:1080\r\n117.82.48.155:8998\r\n122.96.91.115:8123\r\n1.48.236.22:3128\r\n50.93.197.101:1080\r\n50.93.201.190:1080\r\n101.254.188.198:8080\r\n58.52.201.118:8080\r\n121.234.250.146:8998\r\n121.236.29.93:8998\r\n101.251.199.66:3128\r\n36.56.234.70:8998\r\n222.94.7.103:8123\r\n27.184.137.237:8888\r\n218.66.253.146:8800\r\n180.160.180.93:8118\r\n220.175.252.53:8998\r\n117.95.131.199:8998\r\n171.43.42.176:8998\r\n222.220.211.159:8998\r\n80.87.81.14:8080\r\n113.248.162.16:8998\r\n134.35.232.61:8080\r\n219.216.108.46:8998\r\n113.18.193.16:8000\r\n222.32.6.91:3128\r\n59.66.124.55:8123\r\n14.152.93.79:8080\r\n27.22.161.45:8998\r\n61.149.128.11:8118\r\n50.117.114.98:1080\r\n121.31.149.46:8123\r\n124.202.131.164:8080\r\n114.223.161.221:8118\r\n182.90.111.253:8123\r\n125.111.171.221:8118\r\n61.158.173.14:8080\r\n61.159.175.42:8998\r\n106.88.79.45:8998\r\n182.89.6.14:8123\r\n121.232.245.25:8998\r\n121.14.6.236:80"
        
//        Log.debug(message: "\(iplistStr)")
        
        var ipArrs = [String]()
        ipArrs.append(contentsOf: iplistStr.components(separatedBy: "\r\n"))
        if self.checkProxyIpInfo(proxyIpStr: ipArrs.first!) {
            Log.debug(message: "ip：\(ipArrs.first!) 有效")
        }else {
            Log.debug(message: "ip：\(ipArrs.first!) 无效")
        }
        
//        for ipStr in iplistStr.components(separatedBy: "\r\n") {
//            
//        }
        Log.debug(message: "抓取ip的时间\(Date.localDate)")
    }
    
    func checkProxyIpInfo(proxyIpStr: String) -> Bool {
        let tempArr = proxyIpStr.components(separatedBy: ":")
        let proxyIp: String = tempArr.first!
        let proxyPort: Int = Int(tempArr.last!)!
        let curlObject = CURL(url: "https://www.baidu.com/")
        
        // 发送 http 报头
        let headers = ["Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
                       "Accept-Encoding:gzip, deflate, sdch, br",
                       "Accept-Language:zh-CN,zh;q=0.8,en;q=0.6",
                       "Cache-Control:max-age=0",
                       "Connection:keep-alive",
                       "Upgrade-Insecure-Requests:1",
                       "User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36"
                    ]
        for header in headers {
            let code = curlObject.setOption(CURLOPT_HTTPHEADER, s: header)//发送http报头
            assert(code == CURLE_OK, "failed to set header about \(header)")
        }
        
        // 解码压缩文件
        curlObject.setOption(CURLOPT_ACCEPT_ENCODING, s: "gzip,deflate")

        // 不验证 SSL
//        curlObject.setOption(CURLOPT_SSL_VERIFYPEER, int: 0)
//        curlObject.setOption(CURLOPT_SSL_VERIFYHOST, int: 0)
        
        // 代理
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "Client_Ip: \(proxyIp)")
        curlObject.setOption(CURLOPT_HTTPHEADER, s: "X-Forwarded-For: \(proxyIp)")
        curlObject.setOption(CURLOPT_PROXY, s: proxyIp)
        curlObject.setOption(CURLOPT_PROXYPORT, int: proxyPort)

        // 超时设置
        curlObject.setOption(CURLOPT_TIMEOUT, int: 30)

        
        let response = curlObject.performFully()
//      let head = UTF8Encoding.encode(bytes: response.1)
        let body = UTF8Encoding.encode(bytes: response.2)
        
//        Log.debug(message: "head = \(head), body = \(body)")
        
        curlObject.close()
        
        if body.contains(string: "百度一下，你就知道") {
            return true
        }else {
            return false
        }
//        curlObject.perform {
//            code, header, body in
//            
//            print("请求错误代码：\(code)")
//            print("服务器响应代码：\(curlObject.responseCode)")
//            print("返回头数据：\(header)")
//            print("返回内容数据：\(body)")
//        }
        
        
    }
    
    static func getRandomIP() -> String {
        
        return unUsedIPs[0]
    }
    
}

extension Date {
    static public var localDate: Date {
        let date = Date()
        let zone = TimeZone.current
        let interval = zone.secondsFromGMT(for: date)
        return date.addingTimeInterval(TimeInterval(interval))
    }
}
