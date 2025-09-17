//
//  LWThemeBinder.swift
//  LWUIkit Addons
//
//  作用：
//  - 提供“声明式主题绑定”：把控件的属性与语义色/Token 绑定，切换主题后自动刷新。
//  - 解决当前写法中枚举+switch 分散到各控件、需要手动重刷的问题；提升扩展性与可维护性。
//  - iOS 13+ 纯 UIKit，依赖你现有的 LWThemeManager / LWSemanticColors / LWDesignTokens。
//
//  使用示例：
//  ```swift
//  // 1) 普通控件也能自动随主题刷新（不必继承 Themed*）
//  titleLabel.lw_bind(\.textColor, to: .textPrimary)
//  view.lw_bind(\.backgroundColor, to: .backgroundPrimary)
//  button.lw_bind(\.tintColor, to: .brandPrimary)
//
//  // 2) 自定义“组件样式”（注册一次，处处可用）
//  extension LWThemeRegistry.Button {
//      static let destructive = Self { btn in
//          btn.layer.cornerRadius = LWDesignTokens.radii.m
//          btn.backgroundColor = LWSemanticColors.error
//          btn.setTitleColor(LWSemanticColors.onPrimary, for: .normal)
//      }
//  }
//  myButton.lw_apply(.destructive)   // 切主题自动重算
//
//  // 3) 设置页切换主题依旧：
//  LWThemeManager.shared.switchTo(style: .dark, applyToWindows: true)
//  ```
//
//  特点 / 注意事项：
//  - 以闭包形式保存“如何从 Token 解析颜色/数值”，避免动态颜色只跟随浅/深而不反映品牌盘变化的问题。
//  - 统一监听 .LWThemeDidChange；绑定一次即可，生命周期内自动解绑（deinit）。
//  - 不替代你现有的 LWThemed* 控件；是对普通 UIKit 控件的增强，也让“新增样式”无需改动组件源码。
//

import UIKit
import ObjectiveC

// MARK: - 声明式主题值（从 Design Tokens / 语义色解析具体值）
public struct LWThemeValue<T> {
    let resolve: () -> T
    public init(_ resolve: @escaping () -> T) { self.resolve = resolve }
}

public enum LWThemeValues {
    // 颜色语义值（按需补充）
    public static var textPrimary:      LWThemeValue<UIColor> { .init { LWSemanticColors.textPrimary } }
    public static var textSecondary:    LWThemeValue<UIColor> { .init { LWSemanticColors.textSecondary } }
    public static var onPrimary:        LWThemeValue<UIColor> { .init { LWSemanticColors.onPrimary } }
    public static var backgroundPrimary:LWThemeValue<UIColor> { .init { LWSemanticColors.backgroundPrimary } }
    public static var brandPrimary:     LWThemeValue<UIColor> { .init { LWSemanticColors.brandPrimary } }
    public static var separator:        LWThemeValue<UIColor> { .init { LWSemanticColors.separator } }
    public static var error:            LWThemeValue<UIColor> { .init { LWSemanticColors.error } }
}

// MARK: - 绑定实现
private final class _LWThemeBindingBox: NSObject {
    let apply: () -> Void
    private var token: NSObjectProtocol?
    init(apply: @escaping () -> Void) {
        self.apply = apply
        super.init()
        token = NotificationCenter.default.addObserver(forName: .LWThemeDidChange, object: nil, queue: .main) { [weak self] _ in
            self?.apply()
        }
    }
    deinit {
        if let t = token { NotificationCenter.default.removeObserver(t) }
    }
}

private enum _Assoc {
    static var bindings: UInt8 = 0
}

private extension NSObject {
    var lw_bindings: NSMutableArray {
        if let arr = objc_getAssociatedObject(self, &_Assoc.bindings) as? NSMutableArray { return arr }
        let arr = NSMutableArray()
        objc_setAssociatedObject(self, &_Assoc.bindings, arr, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return arr
    }
    func lw_addBinding(_ box: _LWThemeBindingBox) { lw_bindings.add(box) }
}

// MARK: - UIView 通用绑定
public extension UIView {
    /// 将任意可写属性绑定到主题值；切换主题后自动重新赋值。
    func lw_bind<T>(_ kp: ReferenceWritableKeyPath<UIView, T>, to value: LWThemeValue<T>) {
        let box = _LWThemeBindingBox { [weak self] in
            guard let self = self else { return }
            self[keyPath: kp] = value.resolve()
            self.setNeedsLayout(); self.setNeedsDisplay()
        }
        lw_addBinding(box)
        // 初次赋值
        self[keyPath: kp] = value.resolve()
    }
}

// MARK: - “注册式组件样式”：新增样式不改组件源码
public enum LWThemeRegistry {
    public struct Button {
        let apply: (UIButton) -> Void
        public init(_ apply: @escaping (UIButton) -> Void) { self.apply = apply }
    }
    // 其他类型也可扩展：Label / TextField / NavigationBar / Cell 等
}

public extension UIButton {
    func lw_apply(_ style: LWThemeRegistry.Button) {
        // 绑定一次，主题变化时重新执行样式闭包
        let box = _LWThemeBindingBox { [weak self] in
            guard let self = self else { return }
            style.apply(self)
        }
        lw_addBinding(box)
        style.apply(self) // 初次应用
    }
}
