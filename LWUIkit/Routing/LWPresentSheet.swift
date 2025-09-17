//
//  LWPresentSheet.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：半屏/弹窗统一入口（iOS 15+ 使用 UISheetPresentationController；iOS 14 回退到自定义半屏转场）。
//  - 统一参数：detents、是否显示 grabber、cornerRadius 等。
//  - 与 `LWTransitioning`（自定义半屏）协作作为回退方案。
//
//  用法：
//  ```swift
//  let vc = FilterPanelVC()
//  LWPresentSheet.present(vc, from: self, options: .medium(grabber: true))
//  ```
//

import UIKit
import ObjectiveC

public enum LWSheetDetent {
    case medium           // 约 50%
    case large            // 约 90%
    case customRatio(CGFloat) // 0.3~0.95
}

public struct LWSheetOptions {
    public var detents: [LWSheetDetent]
    public var prefersGrabberVisible: Bool
    public var cornerRadius: CGFloat? // iOS15+ 有系统圆角；iOS14 回退设置 layer.cornerRadius
    
    public init(detents: [LWSheetDetent], prefersGrabberVisible: Bool = true, cornerRadius: CGFloat? = 16) {
        self.detents = detents; self.prefersGrabberVisible = prefersGrabberVisible; self.cornerRadius = cornerRadius
    }
    public static func medium(grabber: Bool = true) -> LWSheetOptions { LWSheetOptions(detents: [.medium], prefersGrabberVisible: grabber) }
    public static func large(grabber: Bool = true) -> LWSheetOptions { LWSheetOptions(detents: [.large], prefersGrabberVisible: grabber) }
    public static func custom(ratio: CGFloat, grabber: Bool = true) -> LWSheetOptions { LWSheetOptions(detents: [.customRatio(ratio)], prefersGrabberVisible: grabber) }
}

public enum LWPresentSheet {
    public static func present(_ vc: UIViewController, from presenter: UIViewController, options: LWSheetOptions = .medium(), animated: Bool = true, completion: (() -> Void)? = nil) {
        if #available(iOS 15.0, *) {
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = options.detents.map { d in
                    switch d {
                    case .medium: return .medium()
                    case .large: return .large()
                    case .customRatio(let r):
                        if #available(iOS 16.0, *) {
                            return .custom(resolver: { _ in max(200, UIScreen.main.bounds.height * min(max(r, 0.3), 0.95)) })
                        } else {
                            // iOS15 无自定义 detent：以比例近似选择 medium/large
                            return (r <= 0.7) ? .medium() : .large()
                        }
                    }
                }
                sheet.prefersGrabberVisible = options.prefersGrabberVisible
                if let radius = options.cornerRadius {
                    vc.view.layer.cornerRadius = radius
                    vc.view.layer.masksToBounds = true
                }
            }
            presenter.present(vc, animated: animated, completion: completion)
        } else {
            // iOS14 回退：使用自定义半屏转场（依赖 LWTransitioning）
            let ratio = fallbackRatio(from: options.detents.first)
            let t = _LWSheetTransitionHolder(styleRatio: ratio)
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = t.transitioning
            objc_setAssociatedObject(vc, &_AssociatedKeys.holder, t, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) // 持有者避免释放
            presenter.present(vc, animated: animated, completion: completion)
            if let radius = options.cornerRadius {
                vc.view.layer.cornerRadius = radius
                vc.view.layer.masksToBounds = true
            }
        }
    }
    
    private static func fallbackRatio(from detent: LWSheetDetent?) -> CGFloat {
        switch detent {
        case .medium: return 0.5
        case .large: return 0.9
        case .customRatio(let r): return min(max(r, 0.3), 0.95)
        case .none: return 0.6
        }
    }
}

// 通过持有自定义 transitioning 对象保证其生命周期
private enum _AssociatedKeys { static var holder: UInt8 = 0 }

private final class _LWSheetTransitionHolder {
    let transitioning: UIViewControllerTransitioningDelegate
    init(styleRatio: CGFloat) {
        let t = LWTransitioning(style: .halfSheet(heightRatio: styleRatio))
        transitioning = t as UIViewControllerTransitioningDelegate
    }
}
