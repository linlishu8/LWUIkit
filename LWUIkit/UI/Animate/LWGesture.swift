//
//  LWGesture.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：常用手势的闭包封装（Tap / LongPress / Pan），不再写 selector。
//  - 返回手势对象，便于外部自定义属性/移除。
//  - 通过关联对象保存闭包，生命周期安全。
//
//  用法：
//  ```swift
//  titleView.lw_onTap { [weak self] _ in self?.didTapTitle() }
//  box.lw_onLongPress(minimumPressDuration: 0.5) { g in ... }
//  card.lw_onPan { g in ... }
//  ```
//

import UIKit
import ObjectiveC

private final class _LWGestureTarget: NSObject {
    let action: (UIGestureRecognizer) -> Void
    init(_ action: @escaping (UIGestureRecognizer) -> Void) { self.action = action }
    @objc func handle(_ g: UIGestureRecognizer) { action(g) }
}

private enum _LWGestureKeys {
    static var holders: UInt8 = 0 
}
private func _lw_appendTarget(to view: UIView, _ target: _LWGestureTarget) {
    var arr = objc_getAssociatedObject(view, &_LWGestureKeys.holders) as? NSMutableArray
    if arr == nil { arr = NSMutableArray(); objc_setAssociatedObject(view, &_LWGestureKeys.holders, arr!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    arr!.add(target)
}

public extension UIView {
    @discardableResult
    func lw_onTap(numberOfTaps: Int = 1, cancelsTouchesInView: Bool = true, _ action: @escaping (UITapGestureRecognizer) -> Void) -> UITapGestureRecognizer {
        let target = _LWGestureTarget { g in action(g as! UITapGestureRecognizer) }
        let g = UITapGestureRecognizer(target: target, action: #selector(_LWGestureTarget.handle(_:)))
        g.numberOfTapsRequired = numberOfTaps
        g.cancelsTouchesInView = cancelsTouchesInView
        addGestureRecognizer(g); isUserInteractionEnabled = true
        _lw_appendTarget(to: self, target)
        return g
    }
    
    @discardableResult
    func lw_onLongPress(minimumPressDuration: TimeInterval = 0.5, _ action: @escaping (UILongPressGestureRecognizer) -> Void) -> UILongPressGestureRecognizer {
        let target = _LWGestureTarget { g in action(g as! UILongPressGestureRecognizer) }
        let g = UILongPressGestureRecognizer(target: target, action: #selector(_LWGestureTarget.handle(_:)))
        g.minimumPressDuration = minimumPressDuration
        addGestureRecognizer(g); isUserInteractionEnabled = true
        _lw_appendTarget(to: self, target)
        return g
    }
    
    @discardableResult
    func lw_onPan(_ action: @escaping (UIPanGestureRecognizer) -> Void) -> UIPanGestureRecognizer {
        let target = _LWGestureTarget { g in action(g as! UIPanGestureRecognizer) }
        let g = UIPanGestureRecognizer(target: target, action: #selector(_LWGestureTarget.handle(_:)))
        addGestureRecognizer(g); isUserInteractionEnabled = true
        _lw_appendTarget(to: self, target)
        return g
    }
}
