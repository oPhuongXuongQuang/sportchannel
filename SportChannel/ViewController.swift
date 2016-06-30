//
//  ViewController.swift
//  SportChannel
//
//  Created by Quang Phương on 6/23/16.
//  Copyright © 2016 Quang Phương. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var webServer:GCDWebServer!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webView = WKWebView(frame: self.view.frame, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = self;
        self.view.addSubview(webView)
        let baseURL = NSBundle.mainBundle().bundleURL
        print("URL : " + baseURL.absoluteString)
        if #available(iOS 9.0, *) {
            initWebServer(NSURL.fileURLWithPath("sportchannel_web", relativeToURL: baseURL).absoluteURL)
        } else {
            // Fallback on earlier versions
            let urlStr = NSString.init(format: "%@/%@", baseURL, "sportchannel_web") as String
            initWebServer(NSURL(string: urlStr)!)
        }
        
        let basePath = NSURL(string: "http://localhost:9090/index.html")
        let request = NSURLRequest(URL: basePath!)
        webView.loadRequest(request)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func initWebServer(url:NSURL) -> Void {
        webServer = GCDWebServer()
        
        webServer.addDefaultHandlerForMethod("GET", requestClass: GCDWebServerRequest.classForCoder(), processBlock: {(request:GCDWebServerRequest?) -> GCDWebServerResponse in
            let page = request!.URL
            let path = page.path
            let filePath = NSString(format: "%@%@",url , path!)
            let sfilePath = filePath.substringFromIndex(7) as String
            if (page.lastPathComponent!.hasSuffix("html")) {
                var html = ""
                do {
                    try html = NSString(contentsOfFile: sfilePath, encoding: NSUTF8StringEncoding) as String
                }
                catch {
                    html = ""
                }
                return GCDWebServerDataResponse(HTML: html)
            } else {
                let data = NSData(contentsOfFile: sfilePath)
                if(data != nil) {
                    var type = "image/jpeg"
                    if(page.lastPathComponent!.hasSuffix("jpg")) {
                        type = "image/jpeg"
                    } else if(page.lastPathComponent!.hasSuffix("png")){
                        type = "image/png"
                    } else if(page.lastPathComponent!.hasSuffix("css")){
                        type = "text/css"
                    } else if(page.lastPathComponent!.hasSuffix("js")){
                        type = "text/javascript"
                    } else {
                        return GCDWebServerDataResponse(data: data, contentType: "text")
                    }
                    return GCDWebServerDataResponse(data: data, contentType: type)
                } else {
                    return GCDWebServerDataResponse(HTML: NSString(format: "<html><body><p>404 : unknown file %@ World</p></body></html>",page.absoluteString) as String)
                }
            }
        })
        webServer.startWithPort(9090, bonjourName: "")
        print("Server start with URL : " + webServer.serverURL.absoluteString)
    }
    
}

extension ViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
}

