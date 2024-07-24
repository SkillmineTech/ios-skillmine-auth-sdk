import SwiftUI
import WebKit
import Combine

@available(iOS 13.0, *)
public struct AuthenticatorView: UIViewRepresentable {
    @ObservedObject var viewModel: AuthenticatorViewModel
    
    public init(viewModel: AuthenticatorViewModel) {
        self.viewModel = viewModel
    }

    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        viewModel.setupWebView(webView)
        return webView
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) { }

    public func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    public class Coordinator: NSObject, WKNavigationDelegate {
        var viewModel: AuthenticatorViewModel

        init(viewModel: AuthenticatorViewModel) {
            self.viewModel = viewModel
        }

        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            let urlString = url.absoluteString

            if urlString.starts(with: "https://nightly-accounts.complyment.com/profile/personal-detail") {
                decisionHandler(.cancel)
                return
            }

            if urlString.starts(with: "http://localhost:3000") {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let accessToken = components.queryItems?.first(where: { $0.name == "access_token" })?.value {
                    self.viewModel.accessToken.send(accessToken)
                    decisionHandler(.cancel)
                    return
                }
            }

            decisionHandler(.allow)
        }
    }
}

@available(iOS 13.0, *)
public class AuthenticatorViewModel: ObservableObject {
    var urlString: String
    var clientId: String
    var redirectUri: String

    public let accessToken = PassthroughSubject<String, Never>()

    public init(urlString: String, clientId: String, redirectUri: String) {
        self.urlString = urlString
        self.clientId = clientId
        self.redirectUri = redirectUri
    }

    func setupWebView(_ webView: WKWebView) {
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
        webView.load(request)
    }
}
