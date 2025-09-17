//
//  LWThemedView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：主题感知的 View 基类，自动监听主题变化并刷新样式。
//  - 子类只需覆盖 `applyTheme()`，在里面读取 LWSemanticColors/LWDesignTokens。
//

import UIKit

open class LWThemedView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func commonInit() {
        isOpaque = false
        backgroundColor = .clear
        // 初始化时先套用一次主题
        applyTheme()
        // 监听主题切换
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChanged), name: .LWThemeDidChange, object: nil)
        // 监听深浅色切换（system 模式下）
        if #available(iOS 13.0, *) {
            // traitCollectionDidChange 会被系统调用，此处无需额外监听
        }
    }

    /// 子类覆盖：在此读取 LWSemanticColors/LWDesignTokens 进行样式设置
    open func applyTheme() {
        // 默认实现：设置通用背景色，可在子类中覆盖
        backgroundColor = LWSemanticColors.backgroundPrimary
    }

    @objc private func onThemeChanged() {
        applyTheme()
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 17.0, *) {
            return
        } else {
            super.traitCollectionDidChange(previousTraitCollection)
            
        }
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            applyTheme()
        }
    }
}
