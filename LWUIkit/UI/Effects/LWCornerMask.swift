//
//  LWCornerMask.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：圆角/指定角遮罩的便捷封装。
//

import UIKit

public struct LWCornerMask: OptionSet {
    public let rawValue: UInt
    public init(rawValue: UInt) { self.rawValue = rawValue }
    public static let topLeft     = LWCornerMask(rawValue: 1 << 0)
    public static let topRight    = LWCornerMask(rawValue: 1 << 1)
    public static let bottomLeft  = LWCornerMask(rawValue: 1 << 2)
    public static let bottomRight = LWCornerMask(rawValue: 1 << 3)

    var caCorners: CACornerMask {
        var m: CACornerMask = []
        if contains(.topLeft) { m.insert(.layerMinXMinYCorner) }
        if contains(.topRight) { m.insert(.layerMaxXMinYCorner) }
        if contains(.bottomLeft) { m.insert(.layerMinXMaxYCorner) }
        if contains(.bottomRight) { m.insert(.layerMaxXMaxYCorner) }
        return m
    }
}

public extension UIView {
    /// 指定角圆角（基于 CALayer.maskedCorners，iOS 11+ 可用，14+稳定）
    func lw_roundCorners(_ corners: LWCornerMask, radius: CGFloat) {
        layer.cornerRadius = radius
        layer.maskedCorners = corners.caCorners
        layer.masksToBounds = true
        // 提示：若 view 的 bounds 变化，需要在 layoutSubviews 里再次调用以确保生效
    }
}
