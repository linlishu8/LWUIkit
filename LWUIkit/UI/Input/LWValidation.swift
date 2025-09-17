//
//  LWValidation.swift
//  iOS 14+ · 纯 UIKit
//
//  职责：统一的校验状态/结果/配色工具。
//

import UIKit

/// 校验状态（用于 TextField/TextView 外观）
public enum LWValidationState: Equatable {
    case normal
    case success(String? = nil)
    case warning(String? = nil)
    case error(String? = nil)

    public var message: String? {
        switch self {
        case .normal: return nil
        case .success(let s): return s
        case .warning(let s): return s
        case .error(let s):   return s
        }
    }
}

public enum LWValidationPalette {
    /// 成功/警告/错误的边框色（可与 DesignSystem/LWSemanticColors 对接）
    public static var success: UIColor { (UIColor(named: "LWValidationSuccess") ?? UIColor.systemGreen) }
    public static var warning: UIColor { (UIColor(named: "LWValidationWarning") ?? UIColor.systemOrange) }
    public static var error:   UIColor { (UIColor(named: "LWValidationError")   ?? UIColor.systemRed) }
    public static var normalBorder: UIColor { (UIColor(named: "LWValidationBorder") ?? UIColor.separator) }
}
