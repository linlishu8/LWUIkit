//
//  LWTypography.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：统一字号/字重/行高的“语义层”，支持自定义字体家族和等宽字体。
//

import UIKit

/// 字体家族配置（无侵入地替换为品牌字/等宽字）
public struct LWFontFamily {
    public enum Sans {
        case system
        case custom(name: String)     // Regular/Base 字体名
    }
    public enum Mono {
        case system
        case custom(name: String)     // 等宽字体名
    }
    public let sans: Sans
    public let mono: Mono
    public init(sans: Sans, mono: Mono) {
        self.sans = sans; self.mono = mono
    }
    public static let system = LWFontFamily(sans: .system, mono: .system)
}

/// 语义字体（字号/字重/动态缩放）
public enum LWTypography {
    /// 标题（大）– 导航大标题/展示型
    case display
    /// 标题（中）– 一级标题
    case title1
    /// 标题（小）– 二级标题
    case title2
    /// 正文 – 常规段落
    case body
    /// 副文 – 次级信息
    case subbody
    /// 说明/脚注
    case caption
    /// 等宽（代码/对齐数值）
    case mono

    /// 获取对应字体（自动适配动态字体）
    public func font(weight: UIFont.Weight? = nil, compatibleWith trait: UITraitCollection? = nil) -> UIFont {
        let base: (size: CGFloat, style: UIFont.TextStyle, defW: UIFont.Weight, mono: Bool)
        switch self {
        case .display: base = (34, .largeTitle, .bold, false)
        case .title1:  base = (28, .title1,     .semibold, false)
        case .title2:  base = (22, .title2,     .semibold, false)
        case .body:    base = (17, .body,       .regular,  false)
        case .subbody: base = (15, .callout,    .regular,  false)
        case .caption: base = (13, .footnote,   .regular,  false)
        case .mono:    base = (15, .body,       .regular,  true)
        }
        let w = weight ?? base.defW
        let f: UIFont
        if base.mono {
            switch LWDesignTokens.fontFamily.mono {
            case .system:
                f = UIFont.monospacedSystemFont(ofSize: base.size, weight: w)
            case .custom(let name):
                f = UIFont(name: name, size: base.size) ?? UIFont.monospacedSystemFont(ofSize: base.size, weight: w)
            }
        } else {
            switch LWDesignTokens.fontFamily.sans {
            case .system:
                f = UIFont.systemFont(ofSize: base.size, weight: w)
            case .custom(let name):
                f = UIFont(name: name, size: base.size) ?? UIFont.systemFont(ofSize: base.size, weight: w)
            }
        }
        return UIFontMetrics(forTextStyle: base.style).scaledFont(for: f, compatibleWith: trait)
    }
}
