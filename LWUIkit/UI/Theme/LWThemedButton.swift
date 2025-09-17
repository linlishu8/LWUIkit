//
//  LWThemedButton.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：主题感知的按钮，提供 primary / secondary / plain 三种常见风格。
//  - primary：主行动按钮（实色填充）
//  - secondary：描边按钮（透明背景）
//  - plain：无背景按钮（仅文字/图标）
//

import UIKit

public enum LWButtonStyle {
    case primary
    case secondary
    case plain
}

open class LWThemedButton: UIButton {
    public var style: LWButtonStyle = .primary { didSet { applyTheme() } }
    public var cornerStyle: CGFloat?  // 若提供则覆盖默认圆角

    public override init(frame: CGRect) {
        super.init(frame: frame); commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder); commonInit()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    private func commonInit() {
        titleLabel?.font = LWTypography.body.font(weight: .semibold)
        layer.masksToBounds = false
        if #available(iOS 15.0, *) {
            var conf = self.configuration ?? UIButton.Configuration.plain()
            conf.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
            self.configuration = conf
        } else {
            self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        }
        applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChanged), name: .LWThemeDidChange, object: nil)
    }

    open func applyTheme() {
        let radius = cornerStyle ?? LWDesignTokens.radii.m
        layer.cornerRadius = radius

        switch style {
        case .primary:
            backgroundColor = LWSemanticColors.primaryFill
            setTitleColor(LWSemanticColors.onPrimary, for: .normal)
            layer.borderWidth = 0
            // 适当阴影
            LWDesignTokens.elevation.apply(to: self, level: 2)

        case .secondary:
            backgroundColor = .clear
            setTitleColor(LWSemanticColors.brandPrimary, for: .normal)
            layer.borderWidth = 1
            layer.borderColor = LWSemanticColors.separator.withAlphaComponent(0.6).cgColor
            LWDesignTokens.elevation.apply(to: self, level: 0)

        case .plain:
            backgroundColor = .clear
            setTitleColor(LWSemanticColors.brandPrimary, for: .normal)
            layer.borderWidth = 0
            LWDesignTokens.elevation.apply(to: self, level: 0)
        }

        // 高亮态轻微透明
        setBackgroundImage(UIImage(), for: .highlighted) // 移除系统背景
    }

    @objc private func onThemeChanged() { applyTheme() }

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
