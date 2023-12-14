import Foundation
import UIKit
import SwiftUI

@objc
class PhoneSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let appDelegate = (UIApplication.shared.delegate as? AppDelegate) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }

        appDelegate.initAppFromScene(connectionOptions: connectionOptions)

        let rootViewController = appDelegate.window?.rootViewController ?? UIViewController()
        rootViewController.view = appDelegate.rootView;

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = rootViewController
        appDelegate.window = window
        self.window = window
        window.makeKeyAndVisible()

        // bootsplash
        RNBootSplash.initWithStoryboard("BootSplash", rootView: appDelegate.rootView)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard let url = userActivity.webpageURL else {
            return
        }

        AppDelegate.shared.application(UIApplication.shared, open: url, options: [:])
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        AppDelegate.shared.application(UIApplication.shared, open: url, options: [:])
    }
}
