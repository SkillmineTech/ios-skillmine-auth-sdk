import UIKit

public protocol UIKitOAuthPresentable: AnyObject {
    func presentAuthenticator(urlString: String, clientId: String, redirectUri: String, onAccessTokenReceived: @escaping (String) -> Void)
    func dismisAuthenticator()
}

public extension UIKitOAuthPresentable where Self: UIViewController {
    func presentAuthenticator(urlString: String, clientId: String, redirectUri: String, onAccessTokenReceived: @escaping (String) -> Void) {
        let webView = Authenticator(urlString: urlString, clientId: clientId, redirectUri: redirectUri, presentableDelegate: self, onAccessTokenReceived: onAccessTokenReceived)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    func dismisAuthenticator() {
        for subview in self.view.subviews {
            if let webView = subview as? Authenticator {
                webView.removeFromSuperview()
            }
        }
    }
}
