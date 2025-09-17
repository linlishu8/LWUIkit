//
//  LWTheme.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：主题模型（浅色 / 深色 / 跟随系统 / 自定义品牌主题）
//  - 内含主题样式枚举、主题实体（包含调色盘与元信息）
//  - 不直接依赖具体窗口，真正的切换交给 LWThemeManager
//

import UIKit

/// 主题样式
public enum LWThemeStyle {
    /// 跟随系统（根据系统深浅色切换）
    case system
    /// 强制浅色
    case light
    /// 强制深色
    case dark
    /// 自定义品牌主题（提供自己的调色盘，仍支持 Light/Dark 两套）
    case custom(palette: LWColorPalette)
}

/// 主题实体（可扩展品牌信息、图标风格等）
public struct LWTheme {
    public let name: String
    public let style: LWThemeStyle
    /// 该主题使用的调色盘（用于语义色取值）。
    /// - 说明：对于 .system/.light/.dark，会使用 LWDesignTokens.palette；对于 .custom，则优先使用传入 palette。
    public let palette: LWColorPalette

    public init(name: String, style: LWThemeStyle, palette: LWColorPalette) {
        self.name = name
        self.style = style
        self.palette = palette
    }

    /// 内置默认主题（蓝色品牌）
    public static var `default`: LWTheme {
        .init(name: "默认主题", style: .system, palette: .default)
    }
}
