//
//  LinkManager.swift
//  ssg
//
//  Created by mykim on 2018. 1. 31..
//  Copyright © 2018년 emart. All rights reserved.
//

import UIKit

class PKHUrlManager: NSObject {
    
    static let shared = PKHUrlManager()
    private override init() {  }
    
    @discardableResult
    func openUrl(url: String, title: String? = nil, data: [String: Any]? = nil) -> Bool {
        print("\t --- ⚡️ PKHUrlkManager OpenUrl ⚡️ --- ")
        print("\t url : \(url)")
        print("\t title : \(title ?? "nil")")
        print("\t data : \(data ?? [String: Any]())\n")
        
        var runCheck = false
        
        // custom Url check
        if let urlParserInfo = PKHURLParser.shared.checkWebUrl(url: url, type: [.customAction]) {
            runCheck = urlParserInfo.runFunction(url: url, instanc: self, data: data)
        }
        
        return runCheck
    }
    
    func assembleModule(identifier: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        return vc
    }
}


extension PKHUrlManager {
    
    @objc func urlFuncNewPage(url: String, data: [String: Any]?) -> Bool {
       
        let vc = assembleModule(identifier: WebViewController.className) as? WebViewController
        vc?.url = URL(string: "https://github.com/pkh0225")
        APP_DELEGATE.navigation?.pushViewController(vc!, animated: true)
        
        return true
    }
    
    
}

