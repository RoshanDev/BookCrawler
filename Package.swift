import PackageDescription

let package = Package(
    name: "BookCrawler",
    dependencies: [
        .Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",majorVersion: 2, minor: 0),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-MongoDB.git", majorVersion: 2, minor: 0),
//        .Package(url: "https://github.com/Hearst-DD/ObjectMapper.git", majorVersion: 2, minor: 2),
//        .Package(url: "https://github.com/LoganWright/Genome.git", majorVersion: 3),
//        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(1,0,0)..<Version(3, .max, .max)),
//        .Package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", versions: Version(1,0,0)..<Version(3, .max, .max)),
        .Package(url: "https://github.com/tid-kijyun/Kanna.git", majorVersion: 2)
    ]
)

