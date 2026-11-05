import UIKit
import Capacitor

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = CAPBridgeViewController()
        window?.makeKeyAndVisible()

        SceneDelegateProxy.shared.scene(scene, willConnectTo: session, options: connectionOptions)

        // Cho phép bàn phím mở khi focus programmatic mà không cần người dùng chạm trực tiếp
        if let bridgeVC = window?.rootViewController as? CAPBridgeViewController {
            bridgeVC.webView?.capacitor.setKeyboardShouldRequireUserInteraction(false)
        }

        // Xử lý 3D Touch / Quick Action khi ứng dụng khởi động từ đầu (Cold Start)
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItem(shortcutItem)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        SceneDelegateProxy.shared.scene(scene, openURLContexts: URLContexts)
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SceneDelegateProxy.shared.scene(scene, continue: userActivity)
    }

    // Xử lý 3D Touch / Quick Action khi ứng dụng đang chạy ngầm hoặc đã mở (Warm Start)
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }

    @discardableResult
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        if shortcutItem.type == "vn.vnpost.gas.add_point" {
            triggerQuickActionAddPoint(retries: 10)
            return true
        }
        return false
    }

    private func triggerQuickActionAddPoint(retries: Int) {
        guard let bridgeVC = window?.rootViewController as? CAPBridgeViewController else {
            if retries > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.triggerQuickActionAddPoint(retries: retries - 1)
                }
            }
            return
        }

        bridgeVC.webView?.capacitor.setKeyboardShouldRequireUserInteraction(false)

        let js = """
        (function() {
            if (typeof window.quickActionAddPoint === 'function') {
                window.quickActionAddPoint();
                return true;
            }
            return false;
        })();
        """

        bridgeVC.webView?.evaluateJavaScript(js) { [weak self] (result, error) in
            let success = (result as? Bool) == true
            if !success && retries > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.triggerQuickActionAddPoint(retries: retries - 1)
                }
            }
        }
    }
}
