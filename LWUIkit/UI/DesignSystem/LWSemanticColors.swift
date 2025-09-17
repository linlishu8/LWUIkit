//
//  LWSemanticColors.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//

//  职责：定义“语义色”，从 LWDesignTokens.palette 中获取 Light/Dark 实际值，
//      并以动态颜色（UIColor(dynamicProvider:)）形式暴露。
//

import UIKit

public enum LWSemanticColors {
    private static func dyn(_ light: UIColor, _ dark: UIColor) -> UIColor {
        UIColor { tc in
            tc.userInterfaceStyle == .dark ? dark : light
        }
    }
    /// 主要背景（列表/内容区域）
    public static var backgroundPrimary: UIColor { dyn(LWDesignTokens.palette.light.backgroundPrimary,
                                                       LWDesignTokens.palette.dark.backgroundPrimary) }
    /// 次级背景（卡片/分组）
    public static var backgroundSecondary: UIColor { dyn(LWDesignTokens.palette.light.backgroundSecondary,
                                                         LWDesignTokens.palette.dark.backgroundSecondary) }
    /// 表层（弹窗/浮层）
    public static var surface: UIColor { dyn(LWDesignTokens.palette.light.surface,
                                             LWDesignTokens.palette.dark.surface) }
    /// 主文本
    public static var textPrimary: UIColor { dyn(LWDesignTokens.palette.light.textPrimary,
                                                 LWDesignTokens.palette.dark.textPrimary) }
    /// 次文本
    public static var textSecondary: UIColor { dyn(LWDesignTokens.palette.light.textSecondary,
                                                   LWDesignTokens.palette.dark.textSecondary) }
    /// 禁用文本
    public static var textDisabled: UIColor { dyn(LWDesignTokens.palette.light.textDisabled,
                                                  LWDesignTokens.palette.dark.textDisabled) }
    /// 分割线
    public static var separator: UIColor { dyn(LWDesignTokens.palette.light.separator,
                                               LWDesignTokens.palette.dark.separator) }
    /// 品牌主色（UI 强调）
    public static var brandPrimary: UIColor { dyn(LWDesignTokens.palette.light.brandPrimary,
                                                  LWDesignTokens.palette.dark.brandPrimary) }
    public static var brandSecondary: UIColor { dyn(LWDesignTokens.palette.light.brandSecondary,
                                                    LWDesignTokens.palette.dark.brandSecondary) }
    /// 主按钮填充
    public static var primaryFill: UIColor { dyn(LWDesignTokens.palette.light.primaryFill,
                                                 LWDesignTokens.palette.dark.primaryFill) }
    /// 主按钮文字
    public static var onPrimary: UIColor { dyn(LWDesignTokens.palette.light.onPrimary,
                                               LWDesignTokens.palette.dark.onPrimary) }
    /// 语义状态
    public static var success: UIColor { dyn(LWDesignTokens.palette.light.success,
                                             LWDesignTokens.palette.dark.success) }
    public static var warning: UIColor { dyn(LWDesignTokens.palette.light.warning,
                                             LWDesignTokens.palette.dark.warning) }
    public static var error: UIColor { dyn(LWDesignTokens.palette.light.error,
                                           LWDesignTokens.palette.dark.error) }
}
