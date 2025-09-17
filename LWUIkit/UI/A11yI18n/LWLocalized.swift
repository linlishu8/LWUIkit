//
//  LWLocalized.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：NSLocalizedString 轻封装 + 运行时切换语言（无需重启）。
//  - 默认“跟随系统”；可以设置固定语言（如 "zh-Hans"、"en"）。
//  - 更改语言后发出通知 `Notification.Name.LWLanguageDidChange`，业务方可刷新界面。
//
//  使用：
//  ```swift
//  LWLocalizationManager.shared.setLanguage(code: "zh-Hans") // 切中文
//  let t = LWLocalized("home_title")   // 取本地化字符串
//  ```
//

import Foundation

public extension Notification.Name {
    /// 语言切换通知（触发后界面应刷新可见文本）
    static let LWLanguageDidChange = Notification.Name("LWLanguageDidChange")
}

/// 语言管理器（单例）
public final class LWLocalizationManager {
    public static let shared = LWLocalizationManager()
    private init() { reloadActiveBundle() }

    private let userDefaultsKey = "LWLocalizationCode"
    /// 当前固定语言代码（nil 表示跟随系统）
    public private(set) var fixedLanguageCode: String? = UserDefaults.standard.string(forKey: "LWLocalizationCode")
    /// 当前激活的 bundle（跟随 fixed 或系统首选）
    private(set) var activeBundle: Bundle = .main

    /// 设置固定语言（传 nil 表示改为跟随系统）
    public func setLanguage(code: String?) {
        fixedLanguageCode = code
        if let code = code { UserDefaults.standard.setValue(code, forKey: userDefaultsKey) }
        else { UserDefaults.standard.removeObject(forKey: userDefaultsKey) }
        reloadActiveBundle()
        NotificationCenter.default.post(name: .LWLanguageDidChange, object: nil)
    }

    /// 实际选择并载入可用的 .lproj bundle
    private func reloadActiveBundle() {
        let codeToUse: String? = fixedLanguageCode
        if let code = codeToUse,
           let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let b = Bundle(path: path) {
            activeBundle = b
        } else {
            // 跟随系统：取首选本地化（或回退 main）
            if let code = Bundle.main.preferredLocalizations.first,
               let path = Bundle.main.path(forResource: code, ofType: "lproj"),
               let b = Bundle(path: path) {
                activeBundle = b
            } else {
                activeBundle = .main
            }
        }
    }
}

/// 便捷函数：等价 NSLocalizedString，但走我们的 activeBundle
@inline(__always)
public func LWLocalized(_ key: String,
                        table: String? = nil,
                        value: String = "",
                        comment: String = "") -> String {
    let bundle = LWLocalizationManager.shared.activeBundle
    return bundle.localizedString(forKey: key, value: value, table: table)
}
