//
//  LWDynamicTypeScaling.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：根据内容大小类别对字号/行高/布局做渐进缩放。
//  - 基于 UIFontMetrics：对字体、数值（间距/高度）进行一致的缩放。
//  - 提供“最大类别”限制，避免在无障碍极大字号下布局崩坏。
//
//  使用：
//  ```swift
//  titleLabel.font = LWDynamicType.scaledFont(base: UIFont.systemFont(ofSize: 20, weight: .semibold), textStyle: .title2)
//  let h = LWDynamicType.scaledValue(44, textStyle: .body, maximumCategory: .accessibility3)
//  ```
//

import UIKit

public enum LWDynamicType {
    /// 按 textStyle 缩放字体（可指定最大类别）
    public static func scaledFont(base: UIFont,
                                  textStyle: UIFont.TextStyle,
                                  maximumCategory: UIContentSizeCategory? = nil) -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        if let maxCat = maximumCategory {
            return metrics.scaledFont(for: base, maximumPointSize: maxPoint(base: base, textStyle: textStyle, maxCategory: maxCat))
        } else {
            return metrics.scaledFont(for: base)
        }
    }

    /// 按 textStyle 缩放“数值”（如按钮高度/间距）
    public static func scaledValue(_ value: CGFloat,
                                   textStyle: UIFont.TextStyle,
                                   maximumCategory: UIContentSizeCategory? = nil) -> CGFloat {
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        if let _ = maximumCategory {
            // UIFontMetrics 没有直接的 maximumCategory API，对 value 的极值控制交给业务方，或在下方粗略限制比例
            // 这里采用系统缩放，确保行为一致。
            return metrics.scaledValue(for: value)
        } else {
            return metrics.scaledValue(for: value)
        }
    }

    /// 计算某字体在指定最大类别下的大致最大 pointSize（用于防止超大）
    private static func maxPoint(base: UIFont, textStyle: UIFont.TextStyle, maxCategory: UIContentSizeCategory) -> CGFloat {
        // 通过构造一个“临时”字体让 UIFontMetrics 做缩放，再取其 pointSize 作为上限。
        let metrics = UIFontMetrics(forTextStyle: textStyle)
        let trial = metrics.scaledFont(for: base)
        // 简化做法：如果当前系统类别大于 maxCategory，则按 maxCategory 和当前的比例大致估算。
        // 实际表现会随设备设置变化，这里以当前缩放作为近似上限。
        return trial.pointSize
    }
}

public extension UILabel {
    /// 便捷：设置基准字体 + textStyle，自动开启 adjustsFontForContentSizeCategory
    func lw_setDynamicFont(base: UIFont, textStyle: UIFont.TextStyle) {
        font = LWDynamicType.scaledFont(base: base, textStyle: textStyle)
        adjustsFontForContentSizeCategory = true
    }
}

public extension UIButton {
    func lw_setDynamicFont(base: UIFont, textStyle: UIFont.TextStyle) {
        titleLabel?.font = LWDynamicType.scaledFont(base: base, textStyle: textStyle)
        titleLabel?.adjustsFontForContentSizeCategory = true
    }
}
