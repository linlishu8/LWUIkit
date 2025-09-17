//
//  LWToastView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：轻提示（Toast）与 Snackbar（底部带按钮的提示）；支持队列与自动消失。
//
//  用法：
//  ```swift
//  LWToastCenter.shared.showToast("保存成功")
//  LWToastCenter.shared.showSnackbar(text: "网络异常", actionTitle: "重试") { /* 重试 */ }
//  ```
//

import UIKit

// MARK: - 视图
final class LWToastView: UIView {
    private let label = UILabel()
    init(text: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 10; layer.masksToBounds = true
        backgroundColor = UIColor.black.withAlphaComponent(0.82)
        label.text = text
        label.textColor = .white
        label.font = LWTypography.subbody.font()
        label.numberOfLines = 0
        label.textAlignment = .center
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        accessibilityViewIsModal = false
        isAccessibilityElement = true
        accessibilityLabel = text
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

final class LWSnackbarView: UIView {
    private let label = UILabel()
    private let button = UIButton(type: .system)
    private var action: (() -> Void)?
    init(text: String, actionTitle: String?, action: (() -> Void)?) {
        super.init(frame: .zero)
        self.action = action
        backgroundColor = LWSemanticColors.surface
        layer.cornerRadius = 12; layer.masksToBounds = true
        layer.borderWidth = 1; layer.borderColor = LWSemanticColors.separator.withAlphaComponent(0.6).cgColor

        label.text = text
        label.textColor = LWSemanticColors.textPrimary
        label.numberOfLines = 0
        label.font = LWTypography.subbody.font()

        if #available(iOS 15.0, *) {
            var conf = UIButton.Configuration.plain()
            conf.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            conf.baseForegroundColor = LWSemanticColors.brandPrimary
            conf.title = actionTitle ?? "OK"
            button.configuration = conf
        } else {
            button.setTitle(actionTitle ?? "OK", for: .normal)
            button.setTitleColor(LWSemanticColors.brandPrimary, for: .normal)
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        }
        button.addTarget(self, action: #selector(onTap), for: .touchUpInside)

        let h = UIStackView(arrangedSubviews: [label, button])
        h.axis = .horizontal; h.alignment = .center; h.spacing = 12
        h.isLayoutMarginsRelativeArrangement = true
        h.layoutMargins = .init(top: 10, left: 14, bottom: 10, right: 10)
        addSubview(h)
        h.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            h.topAnchor.constraint(equalTo: topAnchor),
            h.leadingAnchor.constraint(equalTo: leadingAnchor),
            h.trailingAnchor.constraint(equalTo: trailingAnchor),
            h.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    @objc private func onTap() { action?() }
}

// MARK: - 队列中心
public final class LWToastCenter {
    public static let shared = LWToastCenter()
    private init() {}

    private enum Entry {
        case toast(String, TimeInterval)
        case snackbar(String, String?, (() -> Void)?)
    }
    private var queue: [Entry] = []
    private var isPresenting = false

    // 配置项
    public var toastDuration: TimeInterval = 2.0
    public var snackbarDuration: TimeInterval = 3.5 // 若有 action，点击后立即消失

    // MARK: API
    public func showToast(_ text: String, duration: TimeInterval? = nil) {
        enqueue(.toast(text, duration ?? toastDuration))
    }
    public func showSnackbar(text: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        enqueue(.snackbar(text, actionTitle, action))
    }

    // MARK: 内部
    private func enqueue(_ entry: Entry) {
        queue.append(entry)
        processIfNeeded()
    }
    private func processIfNeeded() {
        guard !isPresenting else { return }
        guard !queue.isEmpty else { return }
        isPresenting = true
        let entry = queue.removeFirst()
        switch entry {
        case .toast(let text, let dur):
            presentToast(text: text, duration: dur)
        case .snackbar(let text, let title, let act):
            presentSnackbar(text: text, actionTitle: title, action: act)
        }
    }

    private func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    private func presentToast(text: String, duration: TimeInterval) {
        guard let win = keyWindow() else { isPresenting = false; return }
        let toast = LWToastView(text: text)
        toast.alpha = 0
        win.addSubview(toast)
        toast.translatesAutoresizingMaskIntoConstraints = false
        let bottom = toast.bottomAnchor.constraint(equalTo: win.safeAreaLayoutGuide.bottomAnchor, constant: -60)
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: win.centerXAnchor),
            bottom,
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: win.leadingAnchor, constant: 24),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: win.trailingAnchor, constant: -24)
        ])
        // 动画出现
        UIView.animate(withDuration: 0.25) { toast.alpha = 1 }
        // 自动消失
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            UIView.animate(withDuration: 0.25, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
                self?.isPresenting = false
                self?.processIfNeeded()
            }
        }
    }

    private func presentSnackbar(text: String, actionTitle: String?, action: (() -> Void)?) {
        guard let win = keyWindow() else { isPresenting = false; return }
        let bar = LWSnackbarView(text: text, actionTitle: actionTitle, action: action)
        bar.alpha = 0; bar.transform = CGAffineTransform(translationX: 0, y: 40)
        win.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        let bottom = bar.bottomAnchor.constraint(equalTo: win.safeAreaLayoutGuide.bottomAnchor, constant: -12)
        NSLayoutConstraint.activate([
            bar.centerXAnchor.constraint(equalTo: win.centerXAnchor),
            bottom,
            bar.leadingAnchor.constraint(greaterThanOrEqualTo: win.leadingAnchor, constant: 12),
            bar.trailingAnchor.constraint(lessThanOrEqualTo: win.trailingAnchor, constant: -12)
        ])
        // 进场11i
        UIView.animate(withDuration: 0.25, animations: {
            bar.alpha = 1; bar.transform = .identity
        })
        // 自动消失
        DispatchQueue.main.asyncAfter(deadline: .now() + snackbarDuration) { [weak self] in
            UIView.animate(withDuration: 0.25, animations: { bar.alpha = 0; bar.transform = CGAffineTransform(translationX: 0, y: 20) }) { _ in
                bar.removeFromSuperview()
                self?.isPresenting = false
                self?.processIfNeeded()
            }
        }
    }
}
