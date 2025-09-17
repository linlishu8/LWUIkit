//
//  LWNavigationCoordinator.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：解耦“UI 层”跳转策略，聚合 push / present / sheet 等常见导航动作。
//  - 不承载业务逻辑：通过注册路由 key → 控制器构建器，实现轻量路由。
//  - 支持 URL 处理（可选）。
//
//  用法：
//  ```swift
//  let coordinator = LWNavigationCoordinator(navigationController: nav)
//  coordinator.register("article/detail") { ctx in ArticleDetailVC(articleID: ctx.params["id"] as? String) }
//  coordinator.navigate(to: "article/detail", params: ["id": "123"], style: .push())
//  // Present
//  coordinator.navigate(to: "filters", style: .present())
//  // URL
//  _ = coordinator.handle(url: URL(string: "myapp://article/detail?id=123")!)
//  ```
//

import UIKit

public struct LWRouteContext {
    public var params: [String: Any]
    public var userInfo: Any?
    public init(params: [String: Any] = [:], userInfo: Any? = nil) { self.params = params; self.userInfo = userInfo }
}

public enum LWNavStyle {
    case push(animated: Bool = true)
    case present(animated: Bool = true)
    case sheet(options: LWSheetOptions = .medium(), animated: Bool = true) // 依赖 LWPresentSheet
}

public final class LWNavigationCoordinator {
    public weak var navigationController: UINavigationController?
    public weak var presenter: UIViewController?   // 当没有 nav 时，从该 VC present
    public init(navigationController: UINavigationController? = nil, presenter: UIViewController? = nil) {
        self.navigationController = navigationController
        self.presenter = presenter
    }

    // 路由注册表：key -> builder
    private var builders: [String: (LWRouteContext) -> UIViewController] = [:]

    public func register(_ key: String, builder: @escaping (LWRouteContext) -> UIViewController) {
        builders[key] = builder
    }
    public func unregister(_ key: String) { builders.removeValue(forKey: key) }

    @discardableResult
    public func navigate(to key: String, params: [String: Any] = [:], userInfo: Any? = nil, style: LWNavStyle = .push()) -> Bool {
        guard let builder = builders[key] else { return false }
        let vc = builder(.init(params: params, userInfo: userInfo))
        switch style {
        case .push(let animated):
            if let nav = navigationController { nav.pushViewController(vc, animated: animated); return true }
            else if let p = presenter { p.navigationController?.pushViewController(vc, animated: animated); return true }
            else { return false }
        case .present(let animated):
            (navigationController ?? presenter)?.present(vc.wrapInNavIfNeeded(), animated: animated, completion: nil)
            return true
        case .sheet(let options, let animated):
            if let from = navigationController ?? presenter {
                LWPresentSheet.present(vc, from: from, options: options, animated: animated)
                return true
            }
            return false
        }
    }

    // URL: 约定 myapp://<path>?a=1&b=2 其中 <path> 即 key
    @discardableResult
    public func handle(url: URL) -> Bool {
        let key = (url.host.map { "/" + $0 } ?? "") + url.path // host+path 组成 key，例如 /article/detail
        var params: [String: Any] = [:]
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach { params[$0.name] = $0.value }
        return navigate(to: key.trimmingCharacters(in: CharacterSet(charactersIn: "/")), params: params)
    }
}

private extension UIViewController {
    func wrapInNavIfNeeded() -> UIViewController {
        if self is UINavigationController { return self }
        return UINavigationController(rootViewController: self)
    }
}
