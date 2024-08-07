# ios-skillmine-auth-sdk

**UIKit Integration**

To present the Authenticator and dismiss it once the token is received, ensure your UIViewController conforms to the UIKitOAuthPresentable protocol and calls presentAuthenticator.
```
import UIKit
import SkillmineAuthSDK

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
            urlString: urlString, // OAuth URL
            clientId: clientId, // Client ID for OAuth
            redirectUri: redirectUri, // Redirect URI after authentication
            onAccessTokenReceived: { [weak self] token in
                // Handle the access token received from the Authenticator
                self?.token = token
            }
        )
    }
}
```

UIKitOAuthPresentable Protocol: Ensures the ViewController can present and dismiss the Authenticator.
presentAuthenticator: Method to present the OAuth login UI. It requires the OAuth URL, Client ID, Redirect URI, and a closure to handle the received access token.<br>


Note: If you need more control over how the Authenticator is presented and dismissed, you can initialize the Authenticator directly as a WKWebView and embed it where needed.

```
Authenticator(
    urlString: String, 
    clientId: String, 
    redirectUri: String, 
    onAccessTokenReceived: @escaping (String) -> Void
)
```
<br>
<br>
<br>

**SwiftUI Integration**

For SwiftUI, create an AuthenticatorView with an AuthenticatorViewModel that exposes an accessToken publisher.

```
import SwiftUI
import SkillmineAuthSDK
import Combine

// SwiftUI View to handle authentication
struct ContentView: View {
    
    // ViewModel for handling Authenticator interactions
    @ObservedObject var viewModel = AuthenticatorViewModel(
        urlString: urlString, // OAuth URL
        clientId: clientId, // Client ID for OAuth
        redirectUri: redirectUri // Redirect URI after authentication
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
AuthenticatorViewModel: Manages the OAuth authentication process and provides the access token through a publisher.<br>
AuthenticatorView: SwiftUI view to present the authentication UI.<br>
accessToken Publisher: Used to handle the access token once it's received.<br>
Note: Adjust the URLs, client IDs, and redirect URIs as needed for your specific use case.
