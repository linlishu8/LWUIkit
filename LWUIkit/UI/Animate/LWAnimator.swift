//
//  LWAnimator.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：对 UIViewPropertyAnimator / UIView 动画做一层统一封装。
//  - 统一入口：普通动画 / 弹簧动画 / 关键帧动画。
//  - 支持“变更约束后动画布局”便捷方法。
//  - 可串行动画步骤（sequence）。
//  - 自动考虑“减少动态效果”（辅助功能）开关。
//
//  用法：
//  ```swift
//  // 普通
//  LWAnimator.animate(duration: 0.25, curve: .easeInOut) {
//      self.view.layoutIfNeeded()
//  }
//
//  // 弹簧
//  LWAnimator.spring(dampingRatio: 0.8, duration: 0.5) {
//      self.badge.transform = .identity
//  }
//
//  // 关键帧
//  LWAnimator.keyframes(total: 0.6) {
//      LWAnimator.addKeyframe(start: 0.0, duration: 0.5) { v.alpha = 0 }
//      LWAnimator.addKeyframe(start: 0.5, duration: 0.5) { v.alpha = 1 }
//  }
//
//  // 串行步骤
//  LWAnimator.sequence([
//      .init(duration: 0.2) { v.alpha = 0.5 },
//      .init(duration: 0.3) { v.alpha = 1.0 }
//  ])
//  ```
//

import UIKit

public enum LWAnimationCurve {
    case easeInOut, easeIn, easeOut, linear
    var timing: UIView.AnimationCurve {
        switch self {
        case .easeInOut: return .easeInOut
        case .easeIn:    return .easeIn
        case .easeOut:   return .easeOut
        case .linear:    return .linear
        }
    }
    var options: UIView.AnimationOptions {
        switch self {
        case .easeInOut: return .curveEaseInOut
        case .easeIn:    return .curveEaseIn
        case .easeOut:   return .curveEaseOut
        case .linear:    return .curveLinear
        }
    }
}

public enum LWAnimator {

    // MARK: - 基础动画
    @discardableResult
    public static func animate(duration: TimeInterval,
                               delay: TimeInterval = 0,
                               curve: LWAnimationCurve = .easeInOut,
                               options: UIView.AnimationOptions = [],
                               animations: @escaping () -> Void,
                               completion: ((Bool) -> Void)? = nil) -> UIViewPropertyAnimator {
        // 辅助功能：减少动态效果，则缩短时长
        let reduce = UIAccessibility.isReduceMotionEnabled
        let d = reduce ? min(0.1, duration * 0.3) : duration
        let animator = UIViewPropertyAnimator(duration: d, curve: curve.timing, animations: animations)
        animator.addCompletion { position in
            completion?(position == .end)
        }
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { animator.startAnimation() }
        } else {
            animator.startAnimation()
        }
        return animator
    }

    // MARK: - 弹簧动画（基于 dampingRatio）
    @discardableResult
    public static func spring(dampingRatio: CGFloat,
                              duration: TimeInterval,
                              delay: TimeInterval = 0,
                              options: UIView.AnimationOptions = [],
                              animations: @escaping () -> Void,
                              completion: ((Bool) -> Void)? = nil) -> UIViewPropertyAnimator {
        let reduce = UIAccessibility.isReduceMotionEnabled
        let d = reduce ? min(0.1, duration * 0.3) : duration
        let animator = UIViewPropertyAnimator(duration: d, dampingRatio: dampingRatio, animations: animations)
        animator.addCompletion { position in completion?(position == .end) }
        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { animator.startAnimation() }
        } else { animator.startAnimation() }
        return animator
    }

    // MARK: - 关键帧动画（使用 UIView.animateKeyframes）
    public static func keyframes(total duration: TimeInterval,
                                 delay: TimeInterval = 0,
                                 options: UIView.KeyframeAnimationOptions = []) {
        let reduce = UIAccessibility.isReduceMotionEnabled
        let d = reduce ? min(0.1, duration * 0.3) : duration
        UIView.animateKeyframes(withDuration: d, delay: delay, options: options, animations: {}, completion: nil)
    }

    /// 添加关键帧（需在 `keyframes(total:)` 调用后的动画块里使用）
    public static func addKeyframe(start relativeStartTime: Double, duration relativeDuration: Double, animations: @escaping () -> Void) {
        UIView.addKeyframe(withRelativeStartTime: relativeStartTime, relativeDuration: relativeDuration, animations: animations)
    }

    // MARK: - 串行动画
    public struct Step {
        public var duration: TimeInterval
        public var delay: TimeInterval
        public var curve: LWAnimationCurve
        public var animations: () -> Void
        public init(duration: TimeInterval, delay: TimeInterval = 0, curve: LWAnimationCurve = .easeInOut, animations: @escaping () -> Void) {
            self.duration = duration; self.delay = delay; self.curve = curve; self.animations = animations
        }
    }
    public static func sequence(_ steps: [Step], completion: (() -> Void)? = nil) {
        guard let first = steps.first else { completion?(); return }
        var rest = steps; rest.removeFirst()
        animate(duration: first.duration, delay: first.delay, curve: first.curve, animations: first.animations) { _ in
            if rest.isEmpty { completion?() } else { sequence(rest, completion: completion) }
        }
    }

    // MARK: - 变更约束后的动画布局
    public static func animateLayout(in view: UIView, duration: TimeInterval = 0.25, curve: LWAnimationCurve = .easeInOut, _ changes: () -> Void) {
        changes()
        view.layoutIfNeeded()
        _ = animate(duration: duration, curve: curve) {
            view.layoutIfNeeded()
        }
    }
}
