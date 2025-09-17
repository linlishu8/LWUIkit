//
//  LWThemedLabel.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：主题感知的 Label，提供常见语义文本风格（主/次/反色）。
//

import UIKit

public enum LWLabelStyle {
    case primary      // 主文案
    case secondary    // 次文案
    case onPrimary    // 置于主按钮上的文字（反色）
}

open class LWThemedLabel: UILabel {
    public var style: LWLabelStyle = .primary { didSet { applyTheme() } }

    public override init(frame: CGRect) {
        super.init(frame: frame); commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder); commonInit()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    private func commonInit() {
        numberOfLines = 0
        font = LWTypography.body.font()
        applyTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(onThemeChanged), name: .LWThemeDidChange, object: nil)
    }

    open func applyTheme() {
        switch style {
        case .primary:   textColor = LWSemanticColors.textPrimary
        case .secondary: textColor = LWSemanticColors.textSecondary
        case .onPrimary: textColor = LWSemanticColors.onPrimary
        }
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
