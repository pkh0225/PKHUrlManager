//
//  WebViewController+Function.swift
//  ssg
//
//  Created by mykim on 2018. 3. 29..
//  Copyright © 2018년 emart. All rights reserved.
//

import UIKit

extension WebViewController {
    
    func customUrlRun(url: String) -> Bool {
        if let urlParserInfo = PKHURLParser.shared.checkWebUrl(url: url, type: [.webAction, .customAction]) {
            
            
            if urlParserInfo.type == .webAction {
                if urlParserInfo.isWebviewMappingSkip {
                    return true
                }
                
                return urlParserInfo.runFunction(url: url, instanc: self)
            }
            else {
                // 함수 실행 결과 값을 봐야 하는 경우
                if urlParserInfo.returnCheck {
                    // customAction인 경우 true이면 함수 실행 성공이라서 결과를 false로 reutrn 해야 webview를 갱신하지 않는다.
                    return urlParserInfo.runFunction(url: url, instanc: PKHUrlManager.shared) == false
                }
                else {
                    // 함수 실행결과와 상관 없이 webview를 갱신하지 않는다.
                    urlParserInfo.runFunction(url: url, instanc: PKHUrlManager.shared)
                    return false
                }
            }
        }
        
        return true
    }
    
    @objc func urlFuncGoogle(url: String, data: [String: Any]?) -> Bool {
        UIAlertController.showMessage("urlFuncGoogle")
        return true
    }
    
    @objc func urlFuncNaver(url: String, data: [String: Any]?) -> Bool {
        UIAlertController.showMessage("urlFuncNaver")
        return false
    }
}


extension UIAlertController {
    
    public static func showMessage(_ message: String) {
        showAlert(title: "", message: message, actions: [UIAlertAction(title: "확인", style: .cancel, handler: nil)])
    }
    
    public static func showAlert(title: String?, message: String?, actions: [UIAlertAction]) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            for action in actions {
                alert.addAction(action)
            }
            if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController, let presenting = navigationController.topViewController {
                presenting.present(alert, animated: true, completion: nil)
            }
        }
    }
}
