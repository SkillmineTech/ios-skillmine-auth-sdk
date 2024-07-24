import WebKit
import SwiftUI
import UIKit

public class Authenticator: WKWebView {
    private var onAccessTokenReceived: ((String) -> Void)?
    weak var presentableDelegate: UIKitOAuthPresentable?
    var redirectUri: String
    
    internal init(urlString: String, clientId: String, redirectUri: String, presentableDelegate: UIKitOAuthPresentable? = nil, onAccessTokenReceived: @escaping (String) -> Void) {
        self.onAccessTokenReceived = onAccessTokenReceived
        self.presentableDelegate = presentableDelegate
        self.redirectUri = redirectUri
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
        loadURL(urlString: urlString, clientId: clientId, redirectUri: redirectUri)
    }
    
    public init(urlString: String, clientId: String, redirectUri: String, onAccessTokenReceived: @escaping (String) -> Void) {
        self.onAccessTokenReceived = onAccessTokenReceived
        self.redirectUri = redirectUri
        super.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.navigationDelegate = self
        loadURL(urlString: urlString, clientId: clientId, redirectUri: redirectUri)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadURL(urlString: String, clientId: String, redirectUri: String) {
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "scope", value: "openid profile user_info_all"),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "groups_info", value: "0"),
            URLQueryItem(name: "response_mode", value: "query")
        ]
        
        guard let secureURL = components.url else {
            return
        }
        
        let request = URLRequest(url: secureURL)
        load(request)
    }
}

extension Authenticator: WKNavigationDelegate {

    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""

        if url.starts(with: redirectUri) {
            let components = URLComponents(string: url)
            let accessToken = components?.queryItems?.first(where: { $0.name == "access_token" })?.value ?? ""

            if !accessToken.isEmpty {
                self.onAccessTokenReceived?(accessToken)
                self.presentableDelegate?.dismisAuthenticator()
            }

            DispatchQueue.main.async {
                decisionHandler(.cancel)
            }
            return
        }

        DispatchQueue.main.async {
            decisionHandler(.allow)
        }
    }
}
