//
//  LWTransitioning.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：Present/Dismiss 自定义转场（卡片 / 半屏）。
//  - 使用方式简单：设置 `modalPresentationStyle = .custom`，把 `transitioningDelegate` 指向下面的封装。
//  - 内置两种样式：`.card(insetTop:)`、`.halfSheet(heightRatio:)`。
//  - 自带半透明遮罩 & 点击空白处关闭；可选手势下拉关闭（attachPanToDismiss）。
//
//  用法：
//  ```swift
//  let vc = DetailVC()
//  let t = LWTransitioning(style: .card(insetTop: 80))
//  vc.modalPresentationStyle = .custom
//  vc.transitioningDelegate = t
//  present(vc, animated: true)
//  // 可开启下拉关闭
//  t.attachPanToDismiss(on: vc)
//  ```
//

import UIKit

public final class LWTransitioning: NSObject {
    public enum Style {
        case card(insetTop: CGFloat)          // 卡片：顶部留白（圆角）
        case halfSheet(heightRatio: CGFloat)  // 半屏：按比例高度（0.5~0.9）
    }

    private let style: Style
    private let dimmingView = UIView()
    private let cornerRadius: CGFloat = 16

    // 交互式关闭
    private var interactionController: UIPercentDrivenInteractiveTransition?
    private weak var trackedVC: UIViewController?
    private var panGesture: UIPanGestureRecognizer?

    public init(style: Style) {
        self.style = style
        super.init()
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        dimmingView.alpha = 0
    }

    // MARK: - 手势下拉关闭（可选）
    public func attachPanToDismiss(on presented: UIViewController) {
        trackedVC = presented
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        panGesture = pan
        presented.view.addGestureRecognizer(pan)
    }

    @objc private func onPan(_ g: UIPanGestureRecognizer) {
        guard let vc = trackedVC else { return }
        let translation = g.translation(in: vc.view)
        let progress = max(0, min(1, translation.y / vc.view.bounds.height))
        switch g.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            vc.dismiss(animated: true, completion: nil)
        case .changed:
            interactionController?.update(progress)
        case .ended, .cancelled:
            let velocity = g.velocity(in: vc.view).y
            let shouldFinish = (progress > 0.33) || (velocity > 800)
            if shouldFinish {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
        default: break
        }
    }
}

// MARK: - Transitioning Delegate
extension LWTransitioning: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(isPresenting: true, style: style, dimmingView: dimmingView, cornerRadius: cornerRadius)
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Animator(isPresenting: false, style: style, dimmingView: dimmingView, cornerRadius: cornerRadius)
    }
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
}

// MARK: - Animator
private final class Animator: NSObject, UIViewControllerAnimatedTransitioning {
    private let isPresenting: Bool
    private let style: LWTransitioning.Style
    private let dimmingView: UIView
    private let cornerRadius: CGFloat

    init(isPresenting: Bool, style: LWTransitioning.Style, dimmingView: UIView, cornerRadius: CGFloat) {
        self.isPresenting = isPresenting
        self.style = style
        self.dimmingView = dimmingView
        self.cornerRadius = cornerRadius
        super.init()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { 0.32 }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        let container = ctx.containerView

        if isPresenting {
            guard let toVC = ctx.viewController(forKey: .to) else { return }
            let toView = toVC.view!
            toView.layer.cornerRadius = cornerRadius
            toView.layer.masksToBounds = true

            // 目标 frame
            let finalFrame = targetFrame(containerBounds: container.bounds, style: style)
            var startFrame = finalFrame
            startFrame.origin.y = container.bounds.height // 自底部出现

            // 背景遮罩
            dimmingView.frame = container.bounds
            dimmingView.alpha = 0
            container.addSubview(dimmingView)

            toView.frame = startFrame
            container.addSubview(toView)

            UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, options: [.curveEaseOut]) {
                self.dimmingView.alpha = 1.0
                toView.frame = finalFrame
            } completion: { finished in
                ctx.completeTransition(finished)
            }
        } else {
            guard let fromVC = ctx.viewController(forKey: .from) else { return }
            let fromView = fromVC.view!
            let finalFrame = CGRect(x: fromView.frame.minX, y: container.bounds.height, width: fromView.frame.width, height: fromView.frame.height)
            UIView.animate(withDuration: transitionDuration(using: ctx), delay: 0, options: [.curveEaseIn]) {
                self.dimmingView.alpha = 0.0
                fromView.frame = finalFrame
            } completion: { finished in
                self.dimmingView.removeFromSuperview()
                ctx.completeTransition(!ctx.transitionWasCancelled)
            }
        }
    }

    private func targetFrame(containerBounds: CGRect, style: LWTransitioning.Style) -> CGRect {
        switch style {
        case .card(let insetTop):
            let top = max(0, insetTop)
            return CGRect(x: 0, y: top, width: containerBounds.width, height: containerBounds.height - top)
        case .halfSheet(let ratio):
            let r = min(max(ratio, 0.3), 0.95)
            let h = containerBounds.height * r
            return CGRect(x: 0, y: containerBounds.height - h, width: containerBounds.width, height: h)
        }
    }
}
