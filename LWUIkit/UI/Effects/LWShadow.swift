//
//  LWShadow.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：阴影便捷封装（与 DesignTokens/LWElevation 可协作）。
//

import UIKit

public struct LWShadow {
    public var color: UIColor
    public var opacity: Float
    public var radius: CGFloat
    public var offset: CGSize

    public init(color: UIColor = UIColor.black, opacity: Float = 0.12, radius: CGFloat = 8, offset: CGSize = .init(width: 0, height: 4)) {
        self.color = color; self.opacity = opacity; self.radius = radius; self.offset = offset
    }

    public func apply(to view: UIView) {
        let layer = view.layer
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        // 提高性能：若已知圆角，可设 shadowPath
        if view.layer.cornerRadius > 0 {
            layer.shadowPath = UIBezierPath(roundedRect: view.bounds, cornerRadius: view.layer.cornerRadius).cgPath
        }
    }
}

public extension UIView {
    /// 快捷应用阴影（在 layoutSubviews 里再次调用可保证 path 正确）
    func lw_applyShadow(_ shadow: LWShadow = LWShadow()) {
        shadow.apply(to: self)
    }
}
