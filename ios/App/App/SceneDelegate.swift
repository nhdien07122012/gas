import UIKit
import WebKit
import WidgetKit
import Capacitor
import CoreLocation

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
        // Đăng ký message handler lấy tọa độ GPS thực tế từ CoreLocation
        bridgeVC.webView?.configuration.userContentController.add(self, name: "gasLocationBridge")

        // Xử lý 3D Touch Quick Action khi khởi động ứng dụng (Cold Start)
        if let shortcutItem = connectionOptions.shortcutItem {
            handleShortcutItem(shortcutItem)
        }

        // Xử lý Deep Link từ Widget (Cold Start)
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
        } else if message.name == "gasLocationBridge" {
            NativeLocationManager.shared.getCurrentLocation { [weak self] result in
                DispatchQueue.main.async {
                    guard let bridgeVC = self?.window?.rootViewController as? CAPBridgeViewController else { return }
                    switch result {
                    case .success(let coord):
                        let js = "if (typeof window.onNativeLocationSuccess === 'function') { window.onNativeLocationSuccess(\(coord.latitude), \(coord.longitude)); }"
                        bridgeVC.webView?.evaluateJavaScript(js, completionHandler: nil)
                    case .failure(let error):
                        let escapedError = error.localizedDescription.replacingOccurrences(of: "'", with: "\\'").replacingOccurrences(of: "\n", with: " ")
                        let js = "if (typeof window.onNativeLocationError === 'function') { window.onNativeLocationError('\(escapedError)'); }"
                        bridgeVC.webView?.evaluateJavaScript(js, completionHandler: nil)
                    }
                }
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
        } else if url.host == "diemtien" || urlStr.contains("diemtien") {
            triggerQuickAction(jsCode: """
            (function() {
                window.location.href = 'diemtien.html';
                return true;
            })();
            """, retries: 10)
        } else if url.host == "report" || urlStr.contains("report") {
            triggerQuickAction(jsCode: """
            (function() {
                if (typeof openReportModal === 'function') {
                    openReportModal();
                    return true;
                } else {
                    window.location.href = 'index.html?action=report';
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

// MARK: - Native Location Manager for iOS App GPS

struct NativeLocationError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

class NativeLocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = NativeLocationManager()
    private let manager = CLLocationManager()
    private var completion: ((Result<CLLocationCoordinate2D, Error>) -> Void)?
    private var timeoutWorkItem: DispatchWorkItem?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func getCurrentLocation(completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        self.completion = completion

        guard CLLocationManager.locationServicesEnabled() else {
            finish(with: .failure(NativeLocationError(message: "Dịch vụ định vị GPS trên iPhone đang tắt. Vui lòng bật trong Cài đặt > Quyền riêng tư.")))
            return
        }

        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .notDetermined:
            startTimeoutTimer()
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            finish(with: .failure(NativeLocationError(message: "Ứng dụng chưa được cấp quyền vị trí. Vui lòng vào Cài đặt iPhone > Gas Manager > Vị trí để cho phép.")))
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        @unknown default:
            finish(with: .failure(NativeLocationError(message: "Trạng thái vị trí không xác định.")))
        }
    }

    private func startUpdating() {
        startTimeoutTimer()
        manager.startUpdatingLocation()
    }

    private func startTimeoutTimer() {
        timeoutWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            self?.manager.stopUpdatingLocation()
            self?.finish(with: .failure(NativeLocationError(message: "Hết thời gian chờ nhận tín hiệu GPS. Vui lòng thử lại.")))
        }
        timeoutWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0, execute: item)
    }

    private func finish(with result: Result<CLLocationCoordinate2D, Error>) {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = nil
        let callback = completion
        completion = nil
        callback?(result)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status: CLAuthorizationStatus
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        handleAuthStatus(status)
    }

    private func handleAuthStatus(_ status: CLAuthorizationStatus) {
        guard completion != nil else { return }
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startUpdating()
        case .denied, .restricted:
            manager.stopUpdatingLocation()
            finish(with: .failure(NativeLocationError(message: "Quyền truy cập vị trí bị từ chối. Vui lòng bật trong Cài đặt iPhone.")))
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        // Nhận tọa độ có độ chính xác hợp lý
        if location.horizontalAccuracy >= 0 {
            manager.stopUpdatingLocation()
            finish(with: .success(location.coordinate))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clErr = error as? CLError, clErr.code == .locationUnknown {
            return
        }
        manager.stopUpdatingLocation()
        finish(with: .failure(error))
    }
}
