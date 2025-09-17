//
//  LWSafeAreaGuide.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  目标：封装 safeArea 常用锚点与“键盘回避”辅助。
//  说明：
//   - 提供便捷方法将视图约束到 safeArea。
//   - 提供一个 LWKeyboardAvoider，自动根据键盘高度调整底部间距或滚动 inset。
//

import UIKit

// MARK: - Safe Area 便捷方法
public extension UIView {
    @discardableResult
    func lw_pinEdgesToSafeArea(insets: UIEdgeInsets = .zero, activate: Bool = true) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        let g = safeAreaLayoutGuide
        let cs = [
            topAnchor.constraint(equalTo: g.topAnchor, constant: insets.top),
            leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -insets.right),
            bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -insets.bottom)
        ]
        if activate { NSLayoutConstraint.activate(cs) }
        return cs
    }
}

// MARK: - 键盘回避辅助
public final class LWKeyboardAvoider {
    public enum Mode {
        case bottomConstraint(NSLayoutConstraint, baseConstant: CGFloat = 0) // 直接改约束常量（通常是内容底部到安全区的约束）
        case scrollView(UIScrollView)                                       // 调整 contentInset/scrollIndicatorInsets
    }
    private let mode: Mode
    private var observerTokens: [NSObjectProtocol] = []

    public init(mode: Mode) { self.mode = mode }
    deinit { stop() }

    public func start() {
        stop()
        let nc = NotificationCenter.default
        let willShow = nc.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] in
            self?.handleKeyboard(note: $0)
        }
        let willHide = nc.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { [weak self] in
            self?.handleKeyboard(note: $0)
        }
        observerTokens = [willShow, willHide]
    }
    public func stop() {
        let nc = NotificationCenter.default
        observerTokens.forEach { nc.removeObserver($0) }
        observerTokens.removeAll()
    }

    private func handleKeyboard(note: Notification) {
        guard let userInfo = note.userInfo else { return }
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curveRaw = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let options = UIView.AnimationOptions(rawValue: curveRaw << 16)

        // 键盘高度相对于当前窗口
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let height: CGFloat
        if let w = window {
            let overlap = w.bounds.maxY - w.convert(endFrame, from: nil).minY
            height = max(0, overlap)
        } else {
            height = 0
        }

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            switch self.mode {
            case .bottomConstraint(let c, let base):
                c.constant = base + height
                (c.firstItem as? UIView)?.superview?.layoutIfNeeded() // 触发布局
                c.isActive = true
                (c.firstItem as? UIView)?.layoutIfNeeded()
            case .scrollView(let sv):
                var inset = sv.contentInset
                inset.bottom = height
                sv.contentInset = inset
                var vsi = sv.verticalScrollIndicatorInsets
                vsi.bottom = height
                sv.verticalScrollIndicatorInsets = vsi
            }
        }
    }
}
