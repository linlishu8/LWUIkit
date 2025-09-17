//
//  LWHaptics.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：触感反馈封装（轻/中/重/软/硬、成功/警告/失败、选择变更）。
//  - 自动做“频率节流”，避免短时间高频触发导致系统忽略。
//  - 遵循“减少动态效果”开关：若开启，默认不触发触感（可通过 alwaysOn 覆盖）。
//

import UIKit

public enum LWHapticImpact {
    case light, medium, heavy, soft, rigid
}
public enum LWHapticNotification {
    case success, warning, error
}

public final class LWHaptics {
    public static let shared = LWHaptics()
    private init() {}

    /// 在用户开启“减少动态效果”时是否仍然触发（默认 false）
    public var alwaysOn: Bool = false
    /// 触发节流最小间隔
    public var minInterval: TimeInterval = 0.06
    private var lastTime: TimeInterval = 0

    private func canFire() -> Bool {
        if !alwaysOn && UIAccessibility.isReduceMotionEnabled { return false }
        let now = CACurrentMediaTime()
        if now - lastTime < minInterval { return false }
        lastTime = now; return true
    }

    public func impact(_ style: LWHapticImpact) {
        guard canFire() else { return }
        let generator: UIImpactFeedbackGenerator
        switch style {
        case .light: generator = UIImpactFeedbackGenerator(style: .light)
        case .medium: generator = UIImpactFeedbackGenerator(style: .medium)
        case .heavy: generator = UIImpactFeedbackGenerator(style: .heavy)
        case .soft:
            if #available(iOS 13.0, *) {
                generator = UIImpactFeedbackGenerator(style: .soft)
            } else { generator = UIImpactFeedbackGenerator(style: .light) }
        case .rigid:
            if #available(iOS 13.0, *) {
                generator = UIImpactFeedbackGenerator(style: .rigid)
            } else { generator = UIImpactFeedbackGenerator(style: .heavy) }
        }
        generator.impactOccurred()
    }

    public func notify(_ type: LWHapticNotification) {
        guard canFire() else { return }
        let g = UINotificationFeedbackGenerator()
        switch type {
        case .success: g.notificationOccurred(.success)
        case .warning: g.notificationOccurred(.warning)
        case .error:   g.notificationOccurred(.error)
        }
    }

    public func selectionChanged() {
        guard canFire() else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
