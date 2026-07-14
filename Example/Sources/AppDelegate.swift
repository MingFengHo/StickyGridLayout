import UIKit
import SwiftUI

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let root: UIViewController
        if #available(iOS 16.0, *), CommandLine.arguments.contains("-swiftUIDemo") {
            let host = UIHostingController(rootView: CitiesGridView())
            host.title = "StickyGrid (SwiftUI)"
            root = UINavigationController(rootViewController: host)
        } else {
            root = UINavigationController(rootViewController: DemoViewController())
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = root
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
