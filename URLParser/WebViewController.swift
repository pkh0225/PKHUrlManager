import WebKit
import UIKit

class WebViewController: UIViewController, UITextFieldDelegate {
    var url: URL?
    var wKWebView: WKWebView!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var goForwardButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wKWebView = WKWebView(frame: containerView.bounds)
        wKWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        wKWebView.backgroundColor = UIColor.darkGray
        containerView.addSubview(wKWebView)
        wKWebView.navigationDelegate = self
        wKWebView.uiDelegate = self
        
        if let url = url {
            let request = URLRequest(url: url)
            wKWebView.load(request)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        wKWebView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }

    @IBAction func onTappedGoBack(_ sender: Any) {
        wKWebView.goBack()
    }

    @IBAction func onTappedGoForward(_ sender: Any) {
        wKWebView.goForward()
    }
    
    @IBAction func onTappedGoogle(_ sender: Any) {
        url = URL(string: "https://www.google.co.kr/")
        let request = URLRequest(url: url!)
        wKWebView.load(request)
    }
    
    @IBAction func onTappedNaver(_ sender: Any) {
        url = URL(string: "https://m.naver.com/")
        let request = URLRequest(url: url!)
        wKWebView.load(request)
    }
    
    @IBAction func onTappedNewPage(_ sender: Any) {
       
        PKHUrlManager.shared.openUrl(url: "https://m.daum.com/")
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        url = URL(string: textField.text!)
        let request = URLRequest(url: url!)
        wKWebView.load(request)
        return true
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // dismiss indicator
      
        // if url is not valid {
        //    decisionHandler(.cancel)
        // }
        
        let url = "\(navigationAction.request)"
        if customUrlRun(url: url) {
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.cancel)
        }
        
        print("\(navigationAction.request)")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // dismiss indicator
      
        goBackButton.isEnabled = webView.canGoBack
        goForwardButton.isEnabled = webView.canGoForward
        navigationItem.title = webView.title
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      // show error dialog
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
