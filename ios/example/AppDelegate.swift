import UIKit
import CarPlay
import React

#if DEBUG
#if FB_SONARKIT_ENABLED
import FlipperKit
#endif
#endif

@main
class AppDelegate: RCTAppDelegate {
    var rootView: UIView?;
    var concurrentRootEnabled = true;
    var storedLaunchOptions: [UIApplication.LaunchOptionsKey: Any]?

    static var shared: AppDelegate { return UIApplication.shared.delegate as! AppDelegate }

    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.moduleName = "example"

        // firebase
        FirebaseApp.configure()

        self.storedLaunchOptions = launchOptions

        return true
    }

    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if (connectingSceneSession.role == UISceneSession.Role.carTemplateApplication) {
            let scene =  UISceneConfiguration(name: "CarPlay", sessionRole: connectingSceneSession.role)
            scene.delegateClass = CarSceneDelegate.self
            return scene
        } else {
            let scene =  UISceneConfiguration(name: "Phone", sessionRole: connectingSceneSession.role)
            scene.delegateClass = PhoneSceneDelegate.self
            return scene
        }
    }

    override func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}

    func initAppFromScene(connectionOptions: UIScene.ConnectionOptions?) {
        if (self.bridge != nil) {
            return;
        }

        let launchOptions = self.connectionOptionsToLaunchOptions(connectionOptions: connectionOptions);

        self.bridge = super.createBridge(with: self, launchOptions: launchOptions)

        #if RCT_NEW_ARCH_ENABLED
            self.bridgeAdapter = RCTSurfacePresenterBridgeAdapter(initWithBridge: self.bridge, contextContainer:_contextContainer);
            self.bridge.surfacePresenter = self.bridgeAdapter.surfacePresenter;

            self.unstable_registerLegacyComponents();
            RCTComponentViewFactory.currentComponentViewFactory().thirdPartyFabricComponentsProvider = self;
        #endif

        self.rootView = self.createRootView(with: self.bridge, moduleName: self.moduleName, initProps: self.prepareInitialProps())
    }

    // not exposed from RCTAppDelegate, recreating.
    func prepareInitialProps() -> [String: Any] {
        var initProps = self.initialProps as? [String: Any] ?? [String: Any]()
        #if RCT_NEW_ARCH_ENABLED
            initProps["kRNConcurrentRoot"] = concurrentRootEnabled()
        #endif

        return initProps
    }

    /**
    Convert ConnectionOptions to LaunchOptions
    When Scenes are used, the launchOptions param in "didFinishLaunchingWithOptions" is always null, and the expected data is provided through SceneDelegate's ConnectionOptions instead but in a different format
    */
    func connectionOptionsToLaunchOptions(connectionOptions: UIScene.ConnectionOptions?) -> [UIApplication.LaunchOptionsKey: Any] {
        var launchOptions: [UIApplication.LaunchOptionsKey: Any] = [:]

        if let storedLaunchOptions = self.storedLaunchOptions {
            launchOptions = storedLaunchOptions
        }

        if let notificationResponse = connectionOptions?.notificationResponse {
            launchOptions[.remoteNotification] = notificationResponse.notification.request.content.userInfo
        }

        if let userActivity = connectionOptions?.userActivities.first {
            let userActivityDictionary: [String: Any] = [
                "UIApplicationLaunchOptionsUserActivityTypeKey": userActivity.activityType,
                "UIApplicationLaunchOptionsUserActivityKey": userActivity
            ]
            launchOptions[.userActivityDictionary] = userActivityDictionary
        }

        if let url = connectionOptions?.urlContexts.first?.url {
            launchOptions[.url] = url
        }

        return launchOptions
    }

    override func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return RCTLinkingManager.application(application, open: url, options: options)
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return RCTLinkingManager.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }

    override func sourceURL(for bridge: RCTBridge!) -> URL! {
        #if DEBUG
            return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index");
        #else
            return Bundle.main.url(forResource:"main", withExtension:"jsbundle")
        #endif
    }
}
