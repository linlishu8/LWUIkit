//
//  LWColorPalette.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：定义“品牌颜色盘（Palette）”及其 Light/Dark 两套 Scheme。
//  - Light/Dark 的差异在这里集中定义，方便品牌化/夜间模式优化。
//

import UIKit

/// 品牌颜色盘（包含浅/深色两套方案）
public struct LWColorPalette {
    public struct Scheme {
        public var brandPrimary: UIColor
        public var brandSecondary: UIColor

        public var backgroundPrimary: UIColor
        public var backgroundSecondary: UIColor
        public var surface: UIColor

        public var textPrimary: UIColor
        public var textSecondary: UIColor
        public var textDisabled: UIColor

        public var separator: UIColor
        public var primaryFill: UIColor
        public var onPrimary: UIColor

        public var success: UIColor
        public var warning: UIColor
        public var error: UIColor

        public init(brandPrimary: UIColor,
                    brandSecondary: UIColor,
                    backgroundPrimary: UIColor,
                    backgroundSecondary: UIColor,
                    surface: UIColor,
                    textPrimary: UIColor,
                    textSecondary: UIColor,
                    textDisabled: UIColor,
                    separator: UIColor,
                    primaryFill: UIColor,
                    onPrimary: UIColor,
                    success: UIColor,
                    warning: UIColor,
                    error: UIColor) {
            self.brandPrimary = brandPrimary
            self.brandSecondary = brandSecondary
            self.backgroundPrimary = backgroundPrimary
            self.backgroundSecondary = backgroundSecondary
            self.surface = surface
            self.textPrimary = textPrimary
            self.textSecondary = textSecondary
            self.textDisabled = textDisabled
            self.separator = separator
            self.primaryFill = primaryFill
            self.onPrimary = onPrimary
            self.success = success
            self.warning = warning
            self.error = error
        }
    }

    public let light: Scheme
    public let dark: Scheme

    public init(light: Scheme, dark: Scheme) {
        self.light = light
        self.dark = dark
    }
}

public extension LWColorPalette {
    /// 默认蓝色品牌基线（可在启动时通过 LWDesignTokens.configure 覆盖）
    static let `default` = LWColorPalette(
        light: Scheme(
            brandPrimary: UIColor(red: 0.10, green: 0.45, blue: 0.95, alpha: 1.0),
            brandSecondary: UIColor(red: 0.12, green: 0.75, blue: 0.65, alpha: 1.0),
            backgroundPrimary: UIColor.systemBackground,
            backgroundSecondary: UIColor.secondarySystemBackground,
            surface: UIColor.secondarySystemBackground,
            textPrimary: UIColor.label,
            textSecondary: UIColor.secondaryLabel,
            textDisabled: UIColor.tertiaryLabel,
            separator: UIColor.separator,
            primaryFill: UIColor(red: 0.10, green: 0.45, blue: 0.95, alpha: 1.0),
            onPrimary: .white,
            success: UIColor.systemGreen,
            warning: UIColor.systemOrange,
            error: UIColor.systemRed
        ),
        dark: Scheme(
            brandPrimary: UIColor(red: 0.25, green: 0.60, blue: 1.00, alpha: 1.0),
            brandSecondary: UIColor(red: 0.16, green: 0.85, blue: 0.75, alpha: 1.0),
            backgroundPrimary: UIColor.systemBackground,
            backgroundSecondary: UIColor.secondarySystemBackground,
            surface: UIColor.tertiarySystemBackground,
            textPrimary: UIColor.label,
            textSecondary: UIColor.secondaryLabel,
            textDisabled: UIColor.tertiaryLabel,
            separator: UIColor.separator,
            primaryFill: UIColor(red: 0.25, green: 0.60, blue: 1.00, alpha: 1.0),
            onPrimary: .black,
            success: UIColor.systemGreen,
            warning: UIColor.systemOrange,
            error: UIColor.systemRed
        )
    )
}
