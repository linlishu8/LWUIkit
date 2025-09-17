//
//  DemoPalettes.swift
//  LWUIkitThemeDemo
//
//  按框架的 LWColorPalette.Scheme 初始化参数补齐 brandPrimary/brandSecondary。
//  每套主题内含 Light/Dark 两份 Scheme。
//

import UIKit

enum DemoBrand: CaseIterable { case ocean, forest, scarlet, grape }

enum DemoPalettes {
    // Ocean（蓝）
    static let ocean: LWColorPalette = {
        var light = LWColorPalette.Scheme(
            brandPrimary: UIColor(red: 0.07, green: 0.46, blue: 0.98, alpha: 1.0),
            brandSecondary: UIColor(red: 0.33, green: 0.60, blue: 1.00, alpha: 1.0),
            backgroundPrimary: .systemBackground,
            backgroundSecondary: .secondarySystemBackground,
            surface: .tertiarySystemBackground,
            textPrimary: .label,
            textSecondary: .secondaryLabel,
            textDisabled: .tertiaryLabel,
            separator: .separator,
            primaryFill: UIColor(red: 0.07, green: 0.46, blue: 0.98, alpha: 1.0), // #1276FA
            onPrimary: .white,
            success: .systemGreen,
            warning: .systemOrange,
            error: .systemRed
        )
        var dark = light
        dark.primaryFill = UIColor(red: 0.18, green: 0.56, blue: 1.00, alpha: 1.0)
        dark.brandPrimary = dark.primaryFill
        dark.brandSecondary = UIColor(red: 0.44, green: 0.70, blue: 1.00, alpha: 1.0)
        return LWColorPalette(light: light, dark: dark)
    }()

    // Forest（绿）
    static let forest: LWColorPalette = {
        var light = LWColorPalette.Scheme(
            brandPrimary: UIColor(red: 0.09, green: 0.62, blue: 0.33, alpha: 1.0),
            brandSecondary: UIColor(red: 0.21, green: 0.72, blue: 0.45, alpha: 1.0),
            backgroundPrimary: .systemBackground,
            backgroundSecondary: .secondarySystemBackground,
            surface: .tertiarySystemBackground,
            textPrimary: .label,
            textSecondary: .secondaryLabel,
            textDisabled: .tertiaryLabel,
            separator: .separator,
            primaryFill: UIColor(red: 0.09, green: 0.62, blue: 0.33, alpha: 1.0), // #179F55
            onPrimary: .white,
            success: .systemGreen,
            warning: .systemOrange,
            error: .systemRed
        )
        var dark = light
        dark.primaryFill = UIColor(red: 0.17, green: 0.74, blue: 0.42, alpha: 1.0)
        dark.brandPrimary = dark.primaryFill
        dark.brandSecondary = UIColor(red: 0.30, green: 0.82, blue: 0.55, alpha: 1.0)
        return LWColorPalette(light: light, dark: dark)
    }()

    // Scarlet（红）
    static let scarlet: LWColorPalette = {
        var light = LWColorPalette.Scheme(
            brandPrimary: UIColor(red: 0.86, green: 0.16, blue: 0.16, alpha: 1.0),
            brandSecondary: UIColor(red: 0.96, green: 0.28, blue: 0.28, alpha: 1.0),
            backgroundPrimary: .systemBackground,
            backgroundSecondary: .secondarySystemBackground,
            surface: .tertiarySystemBackground,
            textPrimary: .label,
            textSecondary: .secondaryLabel,
            textDisabled: .tertiaryLabel,
            separator: .separator,
            primaryFill: UIColor(red: 0.86, green: 0.16, blue: 0.16, alpha: 1.0), // #DB2929
            onPrimary: .white,
            success: .systemGreen,
            warning: .systemOrange,
            error: .systemRed
        )
        var dark = light
        dark.primaryFill = UIColor(red: 0.95, green: 0.27, blue: 0.27, alpha: 1.0)
        dark.brandPrimary = dark.primaryFill
        dark.brandSecondary = UIColor(red: 0.98, green: 0.44, blue: 0.44, alpha: 1.0)
        return LWColorPalette(light: light, dark: dark)
    }()

    // Grape（紫）
    static let grape: LWColorPalette = {
        var light = LWColorPalette.Scheme(
            brandPrimary: UIColor(red: 0.42, green: 0.27, blue: 0.85, alpha: 1.0),
            brandSecondary: UIColor(red: 0.56, green: 0.41, blue: 0.98, alpha: 1.0),
            backgroundPrimary: .systemBackground,
            backgroundSecondary: .secondarySystemBackground,
            surface: .tertiarySystemBackground,
            textPrimary: .label,
            textSecondary: .secondaryLabel,
            textDisabled: .tertiaryLabel,
            separator: .separator,
            primaryFill: UIColor(red: 0.42, green: 0.27, blue: 0.85, alpha: 1.0), // #6C45D9
            onPrimary: .white,
            success: .systemGreen,
            warning: .systemOrange,
            error: .systemRed
        )
        var dark = light
        dark.primaryFill = UIColor(red: 0.56, green: 0.41, blue: 0.98, alpha: 1.0)
        dark.brandPrimary = dark.primaryFill
        dark.brandSecondary = UIColor(red: 0.67, green: 0.53, blue: 1.00, alpha: 1.0)
        return LWColorPalette(light: light, dark: dark)
    }()

    static func of(_ brand: DemoBrand) -> LWColorPalette {
        switch brand {
        case .ocean:   return ocean
        case .forest:  return forest
        case .scarlet: return scarlet
        case .grape:   return grape
        }
    }
}
