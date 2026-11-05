import UIKit
import WebKit
import WidgetKit
import Capacitor

class SceneDelegate: UIResponder, UIWindowSceneDelegate, WKScriptMessageHandler {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: windowScene)
        let bridgeVC = CAPBridgeViewController()
        window?.rootViewController = bridgeVC
        window?.makeKeyAndVisible()

        SceneDelegateProxy.shared.scene(scene, willConnectTo: session, options: connectionOptions)

        // Đăng ký message handler để nhận dữ liệu thống kê từ Web và đồng bộ sang Widget
        bridgeVC.webView?.configuration.userContentController.add(self, name: "gasWidgetBridge")

        // Xử lý 3D Touch Quick Action khi khởi động ứng dụng (Cold Start)
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItem(shortcutItem)
        }

        // Xử lý Deep Link từ Widget
        if let url = connectionOptions.urlContexts.first?.url {
            handleDeepLink(url)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "gasWidgetBridge", let dict = message.body as? [String: Any] {
            let defaults = UserDefaults(suiteName: "group.com.vnpost.gasmanager") ?? UserDefaults.standard
            if let shift = dict["shift"] as? String { defaults.set(shift, forKey: "widget_shift") }
            if let count = dict["count"] as? Int { defaults.set(count, forKey: "widget_count") }
            if let total = dict["total"] as? Int { defaults.set(total, forKey: "widget_total") }
            if let totalFormatted = dict["totalFormatted"] as? String { defaults.set(totalFormatted, forKey: "widget_totalFormatted") }
            if let daNop = dict["daNop"] as? Int { defaults.set(daNop, forKey: "widget_daNop") }
            if let chuaNop = dict["chuaNop"] as? Int { defaults.set(chuaNop, forKey: "widget_chuaNop") }
            if let updatedAt = dict["updatedAt"] as? String { defaults.set(updatedAt, forKey: "widget_updatedAt") }
            defaults.set(Date().timeIntervalSince1970, forKey: "widget_timestamp")

            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        SceneDelegateProxy.shared.scene(scene, openURLContexts: URLContexts)
        if let url = URLContexts.first?.url {
            handleDeepLink(url)
        }
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        SceneDelegateProxy.shared.scene(scene, continue: userActivity)
    }

    // Xử lý Deep Link mở app từ Widget
    private func handleDeepLink(_ url: URL) {
        let urlStr = url.absoluteString
        if url.host == "add_point" || urlStr.contains("add_point") {
            triggerQuickAction(jsCode: """
            (function() {
                if (typeof window.quickActionAddPoint === 'function') {
                    window.quickActionAddPoint();
                    return true;
                }
                return false;
            })();
            """, retries: 10)
        } else if url.host == "clipboard" || urlStr.contains("clipboard") {
            triggerQuickAction(jsCode: """
            (function() {
                if (typeof window.quickActionClipboard === 'function') {
                    window.quickActionClipboard();
                    return true;
                } else {
                    window.location.href = 'clipboard.html';
                    return true;
                }
            })();
            """, retries: 10)
        }
    }

    // Xử lý 3D Touch Quick Action khi ứng dụng đang chạy ngầm hoặc đã mở (Warm Start)
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handled = handleShortcutItem(shortcutItem)
        completionHandler(handled)
    }

    @discardableResult
    func handleShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        if shortcutItem.type == "vn.vnpost.gas.add_point" {
            triggerQuickAction(jsCode: """
            (function() {
                if (typeof window.quickActionAddPoint === 'function') {
                    window.quickActionAddPoint();
                    return true;
                }
                return false;
            })();
            """, retries: 10)
            return true
        } else if shortcutItem.type == "vn.vnpost.gas.clipboard" {
            triggerQuickAction(jsCode: """
            (function() {
                if (typeof window.quickActionClipboard === 'function') {
                    window.quickActionClipboard();
                    return true;
                } else {
                    window.location.href = 'clipboard.html';
                    return true;
                }
            })();
            """, retries: 10)
            return true
        }
        return false
    }

    private func triggerQuickAction(jsCode: String, retries: Int) {
        guard let bridgeVC = window?.rootViewController as? CAPBridgeViewController else {
            if retries > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.triggerQuickAction(jsCode: jsCode, retries: retries - 1)
                }
            }
            return
        }

        bridgeVC.webView?.evaluateJavaScript(jsCode) { [weak self] (result, error) in
            let success = (result as? Bool) == true
            if !success && retries > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
                    self?.triggerQuickAction(jsCode: jsCode, retries: retries - 1)
                }
            }
        }
    }
}
