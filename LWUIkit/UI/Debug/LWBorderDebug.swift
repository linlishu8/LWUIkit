//
//  LWBorderDebug.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：一键给所有子视图添加不同颜色边框，便于定位布局问题。
//  - 提供开启/关闭方法（不会影响 release 逻辑，可在 DEBUG 下使用）。
//

import UIKit

public enum LWBorderDebug {
    /// 为某个根视图的所有子视图添加彩色边框
    public static func enable(on root: UIView, width: CGFloat = 1.0) {
        traverse(root) { view, depth in
            let color = palette[depth % palette.count]
            view.layer.borderWidth = width
            view.layer.borderColor = color.cgColor
        }
    }
    /// 移除边框
    public static func disable(on root: UIView) {
        traverse(root) { view, _ in
            view.layer.borderWidth = 0
            view.layer.borderColor = nil
        }
    }
    /// 递归遍历
    private static func traverse(_ v: UIView, depth: Int = 0, _ visit: (UIView, Int) -> Void) {
        visit(v, depth)
        v.subviews.forEach { traverse($0, depth: depth + 1, visit) }
    }
    private static let palette: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemTeal, .systemPink, .brown, .magenta, .cyan
    ]
}

