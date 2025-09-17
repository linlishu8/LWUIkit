//
//  LWInputAccessoryToolbar.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：上一项 / 下一项 / 完成 的输入附件工具条（用于多个输入框切换）。
//
//  用法：
//  ```swift
//  let manager = LWInputAccessoryManager(responders: [tf1, tf2, tv1])
//  manager.attach() // 会为每个输入框设置统一的 toolbar
//  ```
//

import UIKit

public final class LWInputAccessoryToolbar: UIToolbar {
    public var onPrev: (() -> Void)?
    public var onNext: (() -> Void)?
    public var onDone: (() -> Void)?

    private var prevItem: UIBarButtonItem!
    private var nextItem: UIBarButtonItem!

    public override init(frame: CGRect) {
        super.init(frame: frame)
        sizeToFit()
        barStyle = .default
        isTranslucent = true

        prevItem = UIBarButtonItem(title: "上一项", style: .plain, target: self, action: #selector(prevTapped))
        nextItem = UIBarButtonItem(title: "下一项", style: .plain, target: self, action: #selector(nextTapped))
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneTapped))
        setItems([prevItem, nextItem, flex, done], animated: false)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public func updateEnabled(hasPrev: Bool, hasNext: Bool) {
        prevItem.isEnabled = hasPrev; nextItem.isEnabled = hasNext
    }
    @objc private func prevTapped() { onPrev?() }
    @objc private func nextTapped() { onNext?() }
    @objc private func doneTapped() { onDone?() }
}

public final class LWInputAccessoryManager {
    public var responders: [UIView] { didSet { updateToolbars() } }
    public var toolbar = LWInputAccessoryToolbar()

    public init(responders: [UIView]) {
        self.responders = responders
        toolbar.onPrev = { [weak self] in self?.move(step: -1) }
        toolbar.onNext = { [weak self] in self?.move(step: +1) }
        toolbar.onDone = { [weak self] in self?.currentResponder()?.resignFirstResponder() }
    }

    public func attach() {
        updateToolbars()
    }

    private func updateToolbars() {
        for (i, r) in responders.enumerated() {
            if let tf = r as? UITextField {
                tf.inputAccessoryView = toolbar
                if tf.isFirstResponder { tf.reloadInputViews() }
            } else if let tv = r as? UITextView {
                tv.inputAccessoryView = toolbar
                if tv.isFirstResponder { tv.reloadInputViews() }
            } else {
                // 其他 UIView 默认忽略（其 inputAccessoryView 为只读）
            }
            toolbar.updateEnabled(hasPrev: i > 0, hasNext: i < responders.count - 1)
        }
    }

    private func currentResponder() -> UIView? {
        return responders.first(where: { $0.isFirstResponder })
    }

    private func move(step: Int) {
        guard let current = currentResponder(), let idx = responders.firstIndex(where: { $0 === current }) else { return }
        let next = idx + step
        guard responders.indices.contains(next) else { return }
        responders[next].becomeFirstResponder()
        toolbar.updateEnabled(hasPrev: next > 0, hasNext: next < responders.count - 1)
    }
}
