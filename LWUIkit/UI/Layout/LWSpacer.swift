//
//  LWSpacer.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  目标：提供类似 SwiftUI Spacer 的“弹性空白视图”，用于堆叠中的自适应填充。
//  设计：
//   - 基类为 UIView，通过内容抗拉伸/压缩优先级控制扩展行为。
//   - 可设置 minLength/maxLength 限制尺寸。
//

import UIKit

public final class LWSpacer: UIView {
    public let axis: NSLayoutConstraint.Axis
    public var minLength: CGFloat
    public var maxLength: CGFloat?

    public init(axis: NSLayoutConstraint.Axis, minLength: CGFloat = 0, maxLength: CGFloat? = nil) {
        self.axis = axis; self.minLength = minLength; self.maxLength = maxLength
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        // 弹性：低 Hugging、高 Compression（允许被拉伸填充剩余空间）
        if axis == .vertical {
            setContentHuggingPriority(.defaultLow, for: .vertical)
            setContentCompressionResistancePriority(.required, for: .vertical)
            if minLength > 0 { heightAnchor.constraint(greaterThanOrEqualToConstant: minLength).isActive = true }
            if let max = maxLength { heightAnchor.constraint(lessThanOrEqualToConstant: max).isActive = true }
        } else {
            setContentHuggingPriority(.defaultLow, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .horizontal)
            if minLength > 0 { widthAnchor.constraint(greaterThanOrEqualToConstant: minLength).isActive = true }
            if let max = maxLength { widthAnchor.constraint(lessThanOrEqualToConstant: max).isActive = true }
        }
        accessibilityElementsHidden = true
        isAccessibilityElement = false
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
