//
//  PKHURLParser.swift
//  ssg
//
//  Created by pkh on 2018. 3. 26..
//  Copyright © 2018년 emart. All rights reserved.
//

import Foundation



struct URLParserInfoType: OptionSet {
    let rawValue: Int
    
    static let webAction = URLParserInfoType(rawValue: 1 << 1)
    static let customAction  = URLParserInfoType(rawValue: 1 << 2)
    
}

class PKHURLParser {
    static let shared = PKHURLParser()
    
    var webActionUrlList = [PKHURLParserInfo]()
    var customActionUrlList = [PKHURLParserInfo]()
    
    
    private init() {
        loadUrlParserData()
    }
    
    func loadUrlParserData() {
        
        self.webActionUrlList.append(contentsOf: loadUrlParserWebAction())
        self.customActionUrlList.append(contentsOf: loadUrlParserCustomAction())
        
    }
    
    func loadUrlParserWebAction() -> [PKHURLParserInfo] {
        var result = [PKHURLParserInfo]()
        defer {
            if result.count == 0 {
                print("UrlParserWebAction file load failure")
            }
        }
        
        do {
            if let path = Bundle.main.path(forResource: "UrlParserWebAction", ofType: "data") {
                let content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                if let dic = content.convertToDictionary() {
                    if let list = dic["webActionUrlList"] as? [[String:Any]] {
                        for item in list {
                            let obj = PKHURLParserInfo(item: item)
                            obj.type = .webAction
                            result.append(obj)
                        }
                    }
                }
            }
        }
        catch let error {
            print(">>> error = \(error)")
        }
        
        return result
    }
    
    func loadUrlParserCustomAction() -> [PKHURLParserInfo] {
        var result = [PKHURLParserInfo]()
        defer {
            if result.count == 0 {
                print("UrlParserCustomAction file load failure")
            }
        }
        
        do {
            if let path = Bundle.main.path(forResource: "UrlParserCustomAction", ofType: "data") {
                let content = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                if let dic = content.convertToDictionary() {
                    if let list = dic["customActionUrlList"] as? [[String:Any]] {
                        for item in list {
                            let obj = PKHURLParserInfo(item: item)
                            obj.type = .customAction
                            result.append(obj)
                        }
                    }
                }
                else {
                    
                }
            }
        }
        catch let error {
            print(">>> error = \(error)")
        }
       
        return result
        
    }
    
    
    func checkWebUrl(url: String, type: URLParserInfoType) -> PKHURLParserInfo? {
        if type.contains(.webAction) {
            if let data = checkUrlList(url: url, list: webActionUrlList) {
                return data
            }
        }
        if type.contains(.customAction) {
            if let data = checkUrlList(url: url, list: customActionUrlList) {
                return data
            }
        }
        
        return nil
    }
    
    @inline(__always) func checkUrlList(url: String, list: [PKHURLParserInfo]) -> PKHURLParserInfo? {
    
        for item in list {
            var checkUrlsBool = true
            var checkHostBool = true
            var checkPatterbBool = true
            
            // url 체크
            if let checkUrls = item.checkUrls {
                checkUrlsBool = false
                for checkUrl in checkUrls {
                    if url.contains(checkUrl) {
                        checkUrlsBool = true
                        break
                    }
                }
                guard checkUrlsBool else { continue }
            }
            
            // 호스트 체크
            if let checkUrlsHost = item.checkUrlsHosts {
                checkHostBool = false
                if let strHost = URL(string:url)?.host {
                    for checkHost in checkUrlsHost {
                        if (strHost == checkHost)  {
                            checkHostBool = true
                            break
                        }
                    }
                }
                guard checkHostBool else { continue }
            }
            
            // 정규식 패턴에 일치 하면
            if let patterns = item.patterns {
                checkPatterbBool = false
                for pattern in patterns {
                    if (url as NSString).range(of: pattern, options: .regularExpression).location != NSNotFound {
                        checkPatterbBool = true
                        break
                    }
                }
                guard checkPatterbBool else { continue }
            }
            
            if checkUrlsBool && checkHostBool && checkPatterbBool {
                return item
            }
        }
        
        return nil
    }
    
    
}

let URLParserCallNames = "URLParserCallNames"
class PKHURLParserInfo: NSObject {
    var type: URLParserInfoType = .customAction
    var urlDescription: String?             // 설명
    var name: String = ""                   // 이름
    var returnValue: Bool = true            // 함수 실행 후 결과
    var checkUrls: [String]?                // url에 포함되어 져 있는지 검사 (우선순위 1) url이 있으면 무조건 통과 아래 체크 여부 무시
    var checkUrlsHosts: [String]?           // 호스트 체크 (우선순위 2) 위 조건과 AND 로 실행
    var patterns: [String]?                 // 패턴체크 (우선순위 3) 위 2개 조건과 AND 로 샐행
    var returnCheck: Bool = false           // webview에서만 쓰임 - webview에서 customUrl을 실행하여 함수까지는 실행을 했는데 함수내부에서 조건이 맞지 않아서 그 결과를 가지고 webview에서 처리를 해야 할 경우
    var isWebviewMappingSkip = false        // customUrl을 무시
    var data: Any?                          // Costom Data
    var funNames: [(AnyClass , Selector)]?  // 함수명
    
    var webFunctionRun: Bool = false
    
    init(item: [String:Any]) {

        self.urlDescription = item["description"] as? String
        self.name = item["name"] as? String ?? ""
        self.checkUrls = item["checkUrls"] as? [String]
        self.checkUrlsHosts = item["checkUrlsHost"] as? [String]
        self.patterns = item["patterns"] as? [String]
        self.isWebviewMappingSkip = item["isWebviewMappingSkip"] as? Bool ?? false
        self.returnCheck = item["returnCheck"] as? Bool ?? false
        self.data = item["data"]
        self.funNames = [(AnyClass , Selector)]()
        guard let funNames = item["funNames"] as? [String] else { return }
        for fn in funNames {
            let arrayFN = fn.components(separatedBy: ".")
            if arrayFN.count > 1 {
                guard let classType = swiftClassFromString(arrayFN.first!) else { continue }
                let selector = NSSelectorFromString("\(arrayFN.last!)WithUrl:data:")
                self.funNames?.append( (classType , selector) )
            }
        }
    }
    
    @discardableResult
    func runFunction(url: String, instanc: NSObject? = nil, data: [String: Any]? = nil) -> Bool {
        if type == .webAction && webFunctionRun == true {
            return true
        }
        
        webFunctionRun = true
        defer {
            webFunctionRun = false
        }
        guard let funNames = self.funNames else { return true }
        
        
        
        
        
        var toData: [String: Any?]!
        if data == nil {
            toData = [URLParserCallNames: [self.name], "data": self.data]
        }
        else {
            toData = data
            toData.updateValue(self.data, forKey: "data")
            if var names = toData[URLParserCallNames] as? [String] {
                names.append(self.name)
                toData.updateValue(names, forKey: URLParserCallNames)
            }
            else {
                toData.updateValue([self.name], forKey: URLParserCallNames)
            }
        }
        
        
        for (classType, function) in funNames {
            
            if let aInstanc = instanc , aInstanc.responds(to: function) {
                if let _ = aInstanc.perform(function, with: url, with: toData) {
                    returnValue = true
                }
                else {
                    returnValue = false
                }
                #if DEBUG
                print("\t 🌈 RunFunction \(aInstanc.className).\(function), data: \(toData), return: \(returnValue)\n")
                #else
                #endif
                
            }
            else {
                guard let nsobjAbleType = classType as? NSObject.Type else {
                    preconditionFailure(" >>>>> Class Not NSObject")
                    continue
                }
                let obj = nsobjAbleType.init()
                guard obj.responds(to: function) else {
                    preconditionFailure(" >>>>> \(classType) Not function")
                    continue
                }
                
                if let _ = obj.perform(function, with: url, with: toData) {
                    returnValue = true
                }
                else {
                    returnValue = false
                }
                #if DEBUG
                print("\t 🌈 RunFunction \(nsobjAbleType.className)).\(function), data: \(toData), return: \(returnValue)\n")
                #else
                #endif
                
            }
            
        }
        
        return returnValue
    }
}

extension String {
    public func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

@inline(__always) public func swiftClassFromString(_ className: String, bundleName: String = "WiggleSDK") -> AnyClass? {
    
    // get the project name
    if  let appName = Bundle.main.object(forInfoDictionaryKey:"CFBundleName") as? String {
        // generate the full name of your class (take a look into your "YourProject-swift.h" file)
        let classStringName = "\(appName).\(className)"
        guard let aClass = NSClassFromString(classStringName) else {
            let classStringName = "\(bundleName).\(className)"
            guard let aClass = NSClassFromString(classStringName) else {
                //                print(">>>>>>>>>>>>> [ \(className) ] : swiftClassFromString Create Fail <<<<<<<<<<<<<<")
                return nil
                
            }
            return aClass
        }
        return aClass
    }
    //    print(">>>>>>>>>>>>> [ \(className) ] : swiftClassFromString Create Fail <<<<<<<<<<<<<<")
    return nil
}

private var Object_class_Name_Key : UInt8 = 0
extension NSObject {
    
    public var className: String {
        if let name = objc_getAssociatedObject(self, &Object_class_Name_Key) as? String {
            return name
        }
        else {
            let name = String(describing: type(of:self))
            objc_setAssociatedObject(self, &Object_class_Name_Key, name, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return name
        }
        
        
    }
    
    public class var className: String {
        if let name = objc_getAssociatedObject(self, &Object_class_Name_Key) as? String {
            return name
        }
        else {
            let name = NSStringFromClass(self).components(separatedBy: ".").last ?? ""
            objc_setAssociatedObject(self, &Object_class_Name_Key, name, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return name
        }
    }
}
