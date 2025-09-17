//
//  LWThemeManager.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：
//  - 保存“当前主题”与“主题样式（跟随系统/强制浅/深/自定义）”
//  - 提供切换主题的 API，并：
//      1) 更新 LWDesignTokens.palette（让语义色生效）
//      2) 通知外部刷新（Notification.Name.LWThemeDidChange）
//      3) 可选：对窗口设置 overrideUserInterfaceStyle（强制浅/深）
//  - 可持久化用户选择到 UserDefaults（可选开关）
//

import UIKit

public extension Notification.Name {
    /// 当主题切换时发送（切换样式或调色盘）
    static let LWThemeDidChange = Notification.Name("LWThemeDidChange")
}

public final class LWThemeManager {
    public static let shared = LWThemeManager()
    private init() {}

    /// 当前主题
    public private(set) var current: LWTheme = .default

    /// 是否把主题选择持久化到 UserDefaults
    public var persistsSelection: Bool = true
    private let persistKey = "com.lw.theme.selection"

    /// 读取已持久化的主题样式（若有）
    public func restoreIfNeeded() {
        guard persistsSelection else { return }
        guard let raw = UserDefaults.standard.string(forKey: persistKey) else { return }
        switch raw {
        case "system": switchTo(style: .system)
        case "light":  switchTo(style: .light)
        case "dark":   switchTo(style: .dark)
        default:
            // 自定义主题可以保存为 JSON 或标识，这里仅示例跳过
            break
        }
    }

    /// 切换主题样式（系统/浅/深）
    /// - Parameters:
    ///   - style: 主题样式
    ///   - palette: 可选品牌调色盘（如需覆盖默认）
    ///   - applyToWindows: 是否对所有窗口设置 `overrideUserInterfaceStyle`（仅限 App 内主窗口）
    public func switchTo(style: LWThemeStyle,
                         palette: LWColorPalette? = nil,
                         applyToWindows: Bool = true) {
        let pal: LWColorPalette
        switch style {
        case .custom(let p): pal = p
        default: pal = palette ?? current.palette
        }
        current = LWTheme(name: name(for: style), style: style, palette: pal)

        // 更新 Tokens 的 palette（让 LWSemanticColors 读取新的品牌色）
        LWDesignTokens.configure(
            palette: pal,
            fontFamily: LWDesignTokens.fontFamily,
            spacing: LWDesignTokens.spacing,
            radii: LWDesignTokens.radii,
            elevation: LWDesignTokens.elevation,
            animations: LWDesignTokens.animations
        )

        // 强制浅/深时，设置窗口样式；system 则还原
        if applyToWindows {
            applyInterfaceStyle(style)
        }

        // 持久化
        if persistsSelection {
            UserDefaults.standard.set(rawValue(for: style), forKey: persistKey)
        }

        // 通知外部
        NotificationCenter.default.post(name: .LWThemeDidChange, object: current)
    }

    /// 对所有窗口应用界面样式（浅/深/跟随）
    public func applyInterfaceStyle(_ style: LWThemeStyle) {
        let target: UIUserInterfaceStyle
        switch style {
        case .system: target = .unspecified
        case .light:  target = .light
        case .dark:   target = .dark
        case .custom: target = .unspecified // 自定义一般仍跟随系统，也可自行强制
        }
        DispatchQueue.main.async {
            // 遍历当前应用所有 window，设置 overrideUserInterfaceStyle
            for scene in UIApplication.shared.connectedScenes {
                guard let windowScene = scene as? UIWindowScene else { continue }
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = target
                    // 触发外观刷新
                    window.subviews.forEach { $0.setNeedsLayout(); $0.setNeedsDisplay() }
                }
            }
        }
    }

    // MARK: - Helpers

    private func name(for style: LWThemeStyle) -> String {
        switch style {
        case .system: return "跟随系统"
        case .light:  return "浅色"
        case .dark:   return "深色"
        case .custom: return "自定义品牌"
        }
    }
    private func rawValue(for style: LWThemeStyle) -> String {
        switch style {
        case .system: return "system"
        case .light:  return "light"
        case .dark:   return "dark"
        case .custom: return "custom"
        }
    }
}
