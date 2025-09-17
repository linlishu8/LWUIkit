//
//  LWTextField.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  功能：带内边距、左图标、占位样式、校验状态（成功/警告/错误）的 UITextField 封装。
//
//  用法：
//  ```swift
//  let tf = LWTextField()
//  tf.placeholder = "请输入邮箱"
//  tf.contentInsets = .init(top: 10, left: 12, bottom: 10, right: 12)
//  tf.setLeftIcon(UIImage(systemName: "envelope"))
//  tf.validationState = .normal
//  ```
//

import UIKit

open class LWTextField: UITextField {

    // 内边距（影响 text/placeholder/editing）
    public var contentInsets: UIEdgeInsets = .init(top: 8, left: 10, bottom: 8, right: 10) { didSet { setNeedsLayout() } }
    // 左侧图标容器尺寸
    public var leftIconSize: CGSize = .init(width: 20, height: 20) { didSet { updateLeftViewFrame() } }
    public var leftIconPadding: CGFloat = 8 { didSet { updateLeftViewFrame() } }

    // 校验状态会影响边框颜色/右侧小图标（可选）
    public var showsStateIcon: Bool = true { didSet { applyValidationState() } }
    public var validationState: LWValidationState = .normal { didSet { applyValidationState() } }

    // 占位样式（可统一在外部设置字体/颜色）
    public var placeholderColor: UIColor = .secondaryLabel { didSet { updatePlaceholder() } }
    public var placeholderFont: UIFont? { didSet { updatePlaceholder() } }

    private let borderLayer = CALayer()
    private let stateIconView = UIImageView()
    private let leftContainer = UIView()
    private let leftIconView = UIImageView()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    public required init?(coder: NSCoder) { super.init(coder: coder); commonInit() }

    private func commonInit() {
        borderStyle = .none
        layer.addSublayer(borderLayer)
        borderLayer.borderWidth = 1
        borderLayer.cornerRadius = 10
        borderLayer.masksToBounds = true
        backgroundColor = .secondarySystemBackground

        // 左图标
        leftIconView.contentMode = .scaleAspectFit
        leftContainer.addSubview(leftIconView)
        leftView = leftContainer
        leftViewMode = .always

        // 右侧状态图标
        stateIconView.contentMode = .scaleAspectFit
        rightView = stateIconView
        rightViewMode = .never

        font = UIFont.preferredFont(forTextStyle: .body)
        updateLeftViewFrame()
        updatePlaceholder()
        applyValidationState()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        updateLeftViewFrame()
    }

    private func updateLeftViewFrame() {
        let containerWidth = leftIconSize.width + leftIconPadding * 2
        leftContainer.frame = .init(x: 0, y: 0, width: containerWidth, height: bounds.height)
        leftIconView.frame = .init(x: leftIconPadding,
                                   y: (bounds.height - leftIconSize.height)/2,
                                   width: leftIconSize.width, height: leftIconSize.height)
    }

    private func updatePlaceholder() {
        if let ph = placeholder {
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: placeholderColor,
                .font: placeholderFont ?? font ?? UIFont.preferredFont(forTextStyle: .body)
            ]
            attributedPlaceholder = NSAttributedString(string: ph, attributes: attrs)
        }
    }

    public func setLeftIcon(_ image: UIImage?) {
        leftIconView.image = image
        updateLeftViewFrame()
    }

    // MARK: - 验证态外观
    private func applyValidationState() {
        switch validationState {
        case .normal:
            borderLayer.borderColor = LWValidationPalette.normalBorder.cgColor
            rightViewMode = .never
        case .success:
            borderLayer.borderColor = LWValidationPalette.success.cgColor
            if showsStateIcon {
                stateIconView.image = UIImage(systemName: "checkmark.circle.fill")
                stateIconView.tintColor = LWValidationPalette.success
                rightViewMode = .always
            }
        case .warning:
            borderLayer.borderColor = LWValidationPalette.warning.cgColor
            if showsStateIcon {
                stateIconView.image = UIImage(systemName: "exclamationmark.circle.fill")
                stateIconView.tintColor = LWValidationPalette.warning
                rightViewMode = .always
            }
        case .error:
            borderLayer.borderColor = LWValidationPalette.error.cgColor
            if showsStateIcon {
                stateIconView.image = UIImage(systemName: "xmark.octagon.fill")
                stateIconView.tintColor = LWValidationPalette.error
                rightViewMode = .always
            }
        }
        setNeedsLayout()
    }

    // MARK: - 内边距
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: contentInsets)
        return rect.inset(by: .init(top: 0, left: leftContainer.bounds.width, bottom: 0, right: 0))
    }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = bounds.inset(by: contentInsets)
        let right = (rightViewMode == .always) ? (stateIconView.bounds.width + 8) : 0
        return rect.inset(by: .init(top: 0, left: leftContainer.bounds.width, bottom: 0, right: CGFloat(right)))
    }
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }
}
