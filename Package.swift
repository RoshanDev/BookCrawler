import PackageDescription

let package = Package(
    name: "BookCrawler",
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",majorVersion: 2, minor: 0),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-MongoDB.git", majorVersion: 2, minor: 0),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", majorVersion: 0, minor: 0),
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Curl.git",majorVersion: 2, minor: 0)
    ]
)

