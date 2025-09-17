//
//  LWGradient.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：渐变便捷封装（线性）。
//

import UIKit

public enum LWGradientDirection {
    case topToBottom, bottomToTop, leftToRight, rightToLeft, topLeftToBottomRight, bottomLeftToTopRight

    var points: (CGPoint, CGPoint) {
        switch self {
        case .topToBottom: return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
        case .bottomToTop: return (CGPoint(x: 0.5, y: 1), CGPoint(x: 0.5, y: 0))
        case .leftToRight: return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        case .rightToLeft: return (CGPoint(x: 1, y: 0.5), CGPoint(x: 0, y: 0.5))
        case .topLeftToBottomRight: return (CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        case .bottomLeftToTopRight: return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
        }
    }
}

public final class LWGradientView: UIView {
    public let gradient = CAGradientLayer()
    public var direction: LWGradientDirection = .topToBottom { didSet { update() } }
    public var colors: [UIColor] = [UIColor.black.withAlphaComponent(0.2), UIColor.clear] { didSet { update() } }
    public var locations: [NSNumber]? { didSet { gradient.locations = locations } }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(gradient)
        update()
    }
    public required init?(coder: NSCoder) { super.init(coder: coder); layer.addSublayer(gradient); update() }

    public override func layoutSubviews() { super.layoutSubviews(); gradient.frame = bounds }

    private func update() {
        let (sp, ep) = direction.points
        gradient.startPoint = sp; gradient.endPoint = ep
        gradient.colors = colors.map { $0.cgColor }
        setNeedsLayout()
    }
}
