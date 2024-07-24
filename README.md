# ios-skillmine-auth-sdk

**UIKit Integration:-**

To present the Authenticator and dismiss it once the token is received, ensure your UIViewController conforms to the UIKitOAuthPresentable protocol and calls presentAuthenticator.
```
import UIKit
import Authenticator

// Conforms to UIKitOAuthPresentable to present and dismiss the Authenticator
class ViewController: UIViewController, UIKitOAuthPresentable {
    
    var token = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch token when the view is loaded
        getToken()
    }

    func getToken() {
        // Presents the Authenticator UI for OAuth login
        presentAuthenticator(
            urlString: "https://nightly-accounts-api.complyment.com/authz-srv/authz", // OAuth URL
            clientId: "236b91c8-b2f0-4891-a83c-f358a109a843", // Client ID for OAuth
            redirectUri: "http://localhost:3000", // Redirect URI after authentication
            onAccessTokenReceived: { [weak self] token in
                // Handle the access token received from the Authenticator
                self?.token = token
            }
        )
    }
}
```

UIKitOAuthPresentable Protocol: Ensures the ViewController can present and dismiss the Authenticator.
presentAuthenticator: Method to present the OAuth login UI. It requires the OAuth URL, Client ID, Redirect URI, and a closure to handle the received access token.
Note: If you need more control over how the Authenticator is presented and dismissed, you can initialize the Authenticator directly as a WKWebView and embed it where needed.

```
Authenticator(
    urlString: String, 
    clientId: String, 
    redirectUri: String, 
    onAccessTokenReceived: @escaping (String) -> Void
)
```



**SwiftUI Integration:-**

For SwiftUI, create an AuthenticatorView with an AuthenticatorViewModel that exposes an accessToken publisher.

```
import SwiftUI
import Authenticator
import Combine

// SwiftUI View to handle authentication
struct ContentView: View {
    
    // ViewModel for handling Authenticator interactions
    @ObservedObject var viewModel = AuthenticatorViewModel(
        urlString: "https://nightly-accounts-api.complyment.com/authz-srv/authz", // OAuth URL
        clientId: "236b91c8-b2f0-4891-a83c-f358a109a843", // Client ID for OAuth
        redirectUri: "http://localhost:3000" // Redirect URI after authentication
    )
    
    @State var cancellable: AnyCancellable?

    var body: some View {
        VStack {
            // View to present the Authenticator UI
            AuthenticatorView(viewModel: viewModel)
        }
        .task {
            // Listen to access token updates
            self.cancellable = viewModel.accessToken.sink { token in
                // Handle the access token received from the Authenticator
                print(token)
            }
        }
    }
}
```
AuthenticatorViewModel: Manages the OAuth authentication process and provides the access token through a publisher.
AuthenticatorView: SwiftUI view to present the authentication UI.
accessToken Publisher: Used to handle the access token once it's received.
Note: Adjust the URLs, client IDs, and redirect URIs as needed for your specific use case.
