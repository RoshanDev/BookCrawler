//
//  ProxyManager.swift
//  BookCrawler
//
//  Created by roshan on 2016/12/16.
//
//

import Foundation
import CoreFoundation
import PerfectThread
import PerfectLib
import Dispatch
import PerfectCURL
import cURL
import PerfectLogger

//#include <curl/curl.h>

class ProxyManager {
    
    static let manager = ProxyManager()
    
    var timer: DispatchSourceTimer?
    /// 西刺代理限制的访问时间间隔
    private let xiciAPITimeSpace = 1.5 //15 minutes
    private let xiciAPIUri = "http://proxy.mimvp.com/api/fetch.php?orderid=860161216105833907&num=10&http_type=2&anonymous=5"
    // FIXME: 大象代理不行啊，一直这样 ERROR|没有找到符合条件的IP 。还是要换米扑啊。或者 checkProxyIpInfo 函数中，可以通过 http 校验
//    private let xiciAPIUri = "http://tpv.daxiangdaili.com/ip/?tid=555744041828158&num=10&delay=1&category=2&protocol=https&filter=on"
//    private let xiciAPIUri = "http://tpv.daxiangdaili.com/ip/?tid=555744041828158&num=10&delay=3&category=2"
    private var latestFetchTime: Int = 0
    
    /// 有效 IP 数组
    static var validIPs = ThreadSafeArray<String>()
    
    
    /// 未使用 IP 数组
    static var unUsedIPs = ThreadSafeArray<String>()
    
    init() {
//        self.startLoop()
    }
    
    deinit {
        self.stopLoop()
    }
    
    func startLoop() {
        let duration = xiciAPITimeSpace * 60
        let queue = DispatchQueue(label: "com.scourge.bookCrawler.fetchProxyIp.timer")
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleRepeating(deadline: DispatchTime.now(), interval: DispatchTimeInterval.seconds(Int(duration)))
        timer!.setEventHandler { [weak self] in
            
            if ProxyManager.unUsedIPs.count < 10 {
                self?.loopFetch()
            }
        }
        timer!.resume()
    }
    
    func stopLoop() {
        timer?.cancel()
        timer = nil
    }
    
    private func loopFetch() {
        guard let xiciurl = URL(string: xiciAPIUri) else {
            return
        }
        print("\(xiciurl)");
        self.latestFetchTime = CrawLib.timeStamp()

        let enc = CFStringConvertEncodingToNSStringEncoding(0x0632);
        guard let iplistStr = try? String(contentsOf: xiciurl, encoding: String.Encoding(rawValue: enc)) else {
            return
        }
//        var iplistStr: String;
//        iplistStr = "85.133.184.226:8080\r\n103.35.171.113:8080\r\n109.224.54.18:8080\r\n179.182.220.127:8080\r\n80.115.71.206:80\r\n101.128.100.215:8080\r\n110.136.107.172:3128\r\n223.13.64.106:9797\r\n94.23.118.193:80\r\n116.58.246.190:8080\r\n180.250.59.242:8080\r\n77.240.149.26:8080\r\n103.224.186.2:8080\r\n176.193.78.200:8080\r\n123.57.180.234:3128\r\n222.124.146.81:8080\r\n62.210.37.79:8118\r\n118.168.146.224:3128\r\n49.238.38.131:8080\r\n45.123.43.34:8080\r\n31.199.181.130:8080\r\n185.86.6.84:1983\r\n67.205.145.108:8080\r\n202.179.190.130:8080\r\n190.248.134.246:8080\r\n222.124.129.178:8080\r\n88.199.18.27:8090\r\n182.91.141.151:8080\r\n207.150.188.224:3151\r\n113.66.147.18:9999"//
        
//        Log.debug(message: "\(iplistStr)")
        
        var ipArrs = [String]()
//        for ipTempStr in iplistStr.components(separatedBy: "\r\n") {
//            ipTempStr.components(separatedBy: ":")
//        }

        ipArrs.append(contentsOf: iplistStr.components(separatedBy: "\r\n"))
        
        let fetchProxyIPQueue = Threading.getQueue(name: "fetchProxyIP", type: .concurrent)

//        let rwLock = Threading.RWLock()
        
        for ipStr in ipArrs {
            fetchProxyIPQueue.dispatch {
                if self.checkProxyIpInfo(proxyIpStr: ipStr) {
                    Log.debug(message: "ip：\(ipStr) 有效")
//                    rwLock.doWithWriteLock {
//                    }
                    ProxyManager.validIPs.append(ipStr)
                    ProxyManager.unUsedIPs.append(ipStr)
                }else {
                    Log.debug(message: "ip：\(ipStr) 无效")
                }
            }
        }
        
        Log.debug(message: "抓取ip的时间\(Date.localDate)")
        LogFile.debug("ProxyManager.unUsedIPs.count ===>\(ProxyManager.unUsedIPs.count)")
    }
    
    func checkProxyIpInfo(proxyIpStr: String) -> Bool {
        let tempArr = proxyIpStr.components(separatedBy: ":")
        guard tempArr.count > 1 else {
            return false
        }
        guard let proxyIp: String = tempArr.first,let proxyPort: Int = Int(tempArr.last!) else {
            return false
        }
//        let curlObject = CURL(url: "https://www.baidu.com")
//        let curlObject = CURL(url: "http://blog.huifang.tech")
        
        let curlObject = CURL(url: "http://int.dpool.sina.com.cn/iplookup/iplookup.php")
        
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
//        let body = UTF8Encoding.encode(bytes: response.2)
        
//        Log.debug(message: "body = \(body)")
//        Log.debug(message: "head = \(head), body = \(body)")
        
        curlObject.close()
        
//        if body.contains(string: "百度一下，你就知道") {
//            return true
//        }else {
//            return false
//        }
        
        if response.2.count > 0 {
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
    
    static func getFirstUnusedIP() -> (String, String)? {
        let getIPEvent = Threading.Event()
        getIPEvent.lock()
        guard unUsedIPs.count > 0 else {
            let event = Threading.Event()
            while unUsedIPs.count == 0 {
                event.lock()
                _ = event.wait(seconds: 3)
                event.unlock()
            }
            getIPEvent.unlock()
            return ProxyManager.getFirstUnusedIP()
        }
        let ipStr = unUsedIPs[0]
        unUsedIPs.removeFirst()
        getIPEvent.unlock()
        let ipArrs = ipStr.components(separatedBy: ":")
        guard let ip = ipArrs.first, let port = ipArrs.last else {
            return ProxyManager.getFirstUnusedIP()
        }
        return (ip, port)
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
