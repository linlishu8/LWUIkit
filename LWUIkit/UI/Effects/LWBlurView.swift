//
//  LWBlurView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：对 UIVisualEffectView 的便捷包装，统一风格。
//

import UIKit

public final class LWBlurView: UIView {
    public enum Style {
        case systemThin, systemThick, systemChrome, custom(UIBlurEffect.Style)

        var effect: UIBlurEffect {
            switch self {
            case .systemThin:  return UIBlurEffect(style: .systemThinMaterial)
            case .systemThick: return UIBlurEffect(style: .systemThickMaterial)
            case .systemChrome:return UIBlurEffect(style: .systemChromeMaterial)
            case .custom(let s): return UIBlurEffect(style: s)
            }
        }
    }

    public let effectView: UIVisualEffectView
    public init(style: Style = .systemThin) {
        self.effectView = UIVisualEffectView(effect: style.effect)
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            effectView.topAnchor.constraint(equalTo: topAnchor),
            effectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            effectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            effectView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        layer.masksToBounds = true
        layer.cornerCurve = .continuous
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    public var cornerRadius: CGFloat = 0 { didSet { layer.cornerRadius = cornerRadius } }
    public func update(style: Style) { effectView.effect = style.effect }
}
