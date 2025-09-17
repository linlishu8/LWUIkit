//
//  LWAccessibility.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：常用无障碍辅助（统一设置 label/hint/traits、动态字重适配便捷、朗读播报、无障碍自定义动作）。
//

import UIKit

public enum LWAccessibility {
    // MARK: - 快速设置可达性信息
    /// 一次性为视图设置 accessibilityLabel / accessibilityHint / traits
    @discardableResult
    public static func configure(_ view: UIView,
                                 label: String? = nil,
                                 hint: String? = nil,
                                 value: String? = nil,
                                 traits: UIAccessibilityTraits? = nil,
                                 isElement: Bool = true) -> UIView {
        view.isAccessibilityElement = isElement
        if let label = label { view.accessibilityLabel = label }
        if let hint = hint { view.accessibilityHint = hint }
        if let value = value { view.accessibilityValue = value }
        if let traits = traits { view.accessibilityTraits = traits }
        return view
    }

    // MARK: - 自定义动作（双指轻点等）
    /// 为视图添加一个自定义无障碍动作（会累加）
    public static func addAction(_ view: UIView, name: String, handler: @escaping () -> Bool) {
        let action = UIAccessibilityCustomAction(name: name) { _ in handler() }
        var actions = view.accessibilityCustomActions ?? []
        actions.append(action)
        view.accessibilityCustomActions = actions
    }

    // MARK: - 朗读播报（VoiceOver）
    /// VoiceOver 是否正在运行
    public static var isVoiceOverRunning: Bool { UIAccessibility.isVoiceOverRunning }
    /// 播报一段文字（适合状态改变、错误提示等）
    public static func announce(_ message: String) {
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    // MARK: - 动态字重：快捷 APIs（UIFontMetrics）
    /// 根据动态字重调整字体
    public static func dynamicFont(for base: UIFont, textStyle: UIFont.TextStyle) -> UIFont {
        UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
    }
    /// 根据动态字重调整尺寸（用于高度/间距等）
    public static func dynamicValue(_ value: CGFloat, textStyle: UIFont.TextStyle) -> CGFloat {
        UIFontMetrics(forTextStyle: textStyle).scaledValue(for: value)
    }
}
