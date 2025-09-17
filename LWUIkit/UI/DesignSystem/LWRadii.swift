//
//  LWRadii.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：集中定义“间距刻度 / 圆角刻度 / 阴影层级”三大基础度量。

import UIKit

// MARK: - 间距（Spacing）
public struct LWSpacing {
    public let xxs: CGFloat  // 4
    public let xs: CGFloat   // 8
    public let s: CGFloat    // 12
    public let m: CGFloat    // 16
    public let l: CGFloat    // 24
    public let xl: CGFloat   // 32
    public let xxl: CGFloat  // 40

    public init(xxs: CGFloat, xs: CGFloat, s: CGFloat, m: CGFloat, l: CGFloat, xl: CGFloat, xxl: CGFloat) {
        self.xxs = xxs; self.xs = xs; self.s = s; self.m = m; self.l = l; self.xl = xl; self.xxl = xxl
    }
    public static let `default` = LWSpacing(xxs: 4, xs: 8, s: 12, m: 16, l: 24, xl: 32, xxl: 40)
}

// MARK: - 圆角（Radii）
public struct LWRadii {
    public let s: CGFloat   // 6
    public let m: CGFloat   // 10
    public let l: CGFloat   // 14
    public let xl: CGFloat  // 20

    public init(s: CGFloat, m: CGFloat, l: CGFloat, xl: CGFloat) {
        self.s = s; self.m = m; self.l = l; self.xl = xl
    }
    public static let `default` = LWRadii(s: 6, m: 10, l: 14, xl: 20)

    /// 胶囊圆角（根据高度动态设置）
    public func pill(for height: CGFloat) -> CGFloat { max(0, height / 2.0) }
}

// MARK: - 阴影（Elevation）
public struct LWElevation {
    public struct Spec {
        public let offset: CGSize
        public let radius: CGFloat
        public let opacity: Float
        public let color: UIColor
        public init(offset: CGSize, radius: CGFloat, opacity: Float, color: UIColor) {
            self.offset = offset; self.radius = radius; self.opacity = opacity; self.color = color
        }
    }
    public let level0: Spec  // 无阴影
    public let level1: Spec  // 轻浮起卡片
    public let level2: Spec  // 悬浮
    public let level3: Spec  // 弹窗/浮层
    public let level4: Spec  // 顶层

    public init(level0: Spec, level1: Spec, level2: Spec, level3: Spec, level4: Spec) {
        self.level0 = level0; self.level1 = level1; self.level2 = level2; self.level3 = level3; self.level4 = level4
    }

    public static let `default` = LWElevation(
        level0: Spec(offset: .zero, radius: 0, opacity: 0.0, color: UIColor.black.withAlphaComponent(0.0)),
        level1: Spec(offset: CGSize(width: 0, height: 1), radius: 3,  opacity: 0.10, color: UIColor.black),
        level2: Spec(offset: CGSize(width: 0, height: 3), radius: 6,  opacity: 0.12, color: UIColor.black),
        level3: Spec(offset: CGSize(width: 0, height: 8), radius: 16, opacity: 0.18, color: UIColor.black),
        level4: Spec(offset: CGSize(width: 0, height: 12), radius: 24, opacity: 0.22, color: UIColor.black)
    )
}

public extension LWElevation {
    /// 便捷应用到视图
    func apply(to view: UIView, level: Int) {
        let spec: Spec
        switch level {
        case 1: spec = level1
        case 2: spec = level2
        case 3: spec = level3
        case 4: spec = level4
        default: spec = level0
        }
        view.layer.masksToBounds = false
        view.layer.shadowColor = spec.color.cgColor
        view.layer.shadowOffset = spec.offset
        view.layer.shadowRadius = spec.radius
        view.layer.shadowOpacity = spec.opacity
    }
}

// MARK: - 常用便捷方法
public extension UIEdgeInsets {
    static func all(_ v: CGFloat) -> UIEdgeInsets { .init(top: v, left: v, bottom: v, right: v) }
    static func horizontal(_ v: CGFloat) -> UIEdgeInsets { .init(top: 0, left: v, bottom: 0, right: v) }
    static func vertical(_ v: CGFloat) -> UIEdgeInsets { .init(top: v, left: 0, bottom: v, right: 0) }
}
public extension UIView {
    func lw_addSubviews(_ views: UIView...) { views.forEach { addSubview($0) } }
}
