//
//  LWIntrinsicSizing.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  目标：简化 intrinsicContentSize/内容优先级 的设置与常见尺寸计算。
//

import UIKit

// MARK: - 内容优先级（链式）
public extension UIView {
    @discardableResult
    func lw_hugging(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentHuggingPriority(priority, for: axis); return self
    }
    @discardableResult
    func lw_compression(_ priority: UILayoutPriority, for axis: NSLayoutConstraint.Axis) -> Self {
        setContentCompressionResistancePriority(priority, for: axis); return self
    }
    @discardableResult
    func lw_contentPriority(hugH: UILayoutPriority? = nil, hugV: UILayoutPriority? = nil,
                            compH: UILayoutPriority? = nil, compV: UILayoutPriority? = nil) -> Self {
        if let p = hugH { setContentHuggingPriority(p, for: .horizontal) }
        if let p = hugV { setContentHuggingPriority(p, for: .vertical) }
        if let p = compH { setContentCompressionResistancePriority(p, for: .horizontal) }
        if let p = compV { setContentCompressionResistancePriority(p, for: .vertical) }
        return self
    }
}

// MARK: - 固定 intrinsic 尺寸的轻量视图（用于 Spacer 或占位）
public final class LWIntrinsicSizeView: UIView {
    public var desiredSize: CGSize {
        didSet { invalidateIntrinsicContentSize() }
    }
    public init(size: CGSize) {
        self.desiredSize = size
        super.init(frame: .zero)
        backgroundColor = .clear
        isAccessibilityElement = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    public override var intrinsicContentSize: CGSize { desiredSize }
}

// MARK: - 计算拟合尺寸（Auto Layout Fitting）
public extension UIView {
    /// 给定固定宽度求自适应高度（常用于动态高度 cell/弹窗）
    func lw_fittingHeight(forWidth width: CGFloat) -> CGFloat {
        let target = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        return systemLayoutSizeFitting(target,
                                       withHorizontalFittingPriority: .required,
                                       verticalFittingPriority: .fittingSizeLevel).height
    }
    /// 给定固定高度求自适应宽度
    func lw_fittingWidth(forHeight height: CGFloat) -> CGFloat {
        let target = CGSize(width: UIView.layoutFittingCompressedSize.width, height: height)
        return systemLayoutSizeFitting(target,
                                       withHorizontalFittingPriority: .fittingSizeLevel,
                                       verticalFittingPriority: .required).width
    }
}
