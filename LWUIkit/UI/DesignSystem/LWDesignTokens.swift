//
//  LWDesignTokens.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：
//  - 作为“单一入口”集中配置：调色板、字体家族、间距、圆角、阴影、动画节奏
//  - 暴露当前配置的只读访问
//  - 派发通知：当配置被动态调整时，外部可刷新 UI
//
//  约定：
//  - 颜色、字体、间距等具体定义分别在：
//      LWColorPalette.swift / LWSemanticColors.swift
//      LWTypography.swift
//      LWSpacingRadiiElevation.swift
//      LWAssetCatalog.swift
//  - 为了便于维护，LWDesignTokens 只做“聚合与路由”，不放具体实现细节。
//

import UIKit


// MARK: - 动画（放在 Tokens 里统一管理时长/缓动）
public struct LWAnimations {
    public struct Durations {
        public let ultraFast: TimeInterval  // 0.12
        public let fast: TimeInterval       // 0.20
        public let normal: TimeInterval     // 0.30
        public let slow: TimeInterval       // 0.50
    }
    public struct Timing {
        public let `default`: CAMediaTimingFunction  // easeInOut
        public let easeIn: CAMediaTimingFunction
        public let easeOut: CAMediaTimingFunction
        public let linear: CAMediaTimingFunction
    }
    public let durations: Durations
    public let timing: Timing

    public static let `default` = LWAnimations(
        durations: Durations(ultraFast: 0.12, fast: 0.20, normal: 0.30, slow: 0.50),
        timing: Timing(
            default: CAMediaTimingFunction(name: .easeInEaseOut),
            easeIn:  CAMediaTimingFunction(name: .easeIn),
            easeOut: CAMediaTimingFunction(name: .easeOut),
            linear:  CAMediaTimingFunction(name: .linear)
        )
    )
}

// MARK: - LWDesignTokens 聚合入口
public enum LWDesignTokens {

    // 当前配置（只读访问）
    public private(set) static var palette: LWColorPalette = .default
    public private(set) static var fontFamily: LWFontFamily = .system
    public private(set) static var spacing: LWSpacing = .default
    public private(set) static var radii: LWRadii = .default
    public private(set) static var elevation: LWElevation = .default
    public private(set) static var animations: LWAnimations = .default

    /// 统一配置入口（建议在 App 启动时调用；也支持运行时切换品牌/主题）
    public static func configure(palette: LWColorPalette = .default,
                                 fontFamily: LWFontFamily = .system,
                                 spacing: LWSpacing = .default,
                                 radii: LWRadii = .default,
                                 elevation: LWElevation = .default,
                                 animations: LWAnimations = .default) {
        self.palette = palette
        self.fontFamily = fontFamily
        self.spacing = spacing
        self.radii = radii
        self.elevation = elevation
        self.animations = animations
    }
}
