//
//  LWBaseView.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：约定「三段式」搭建流程 —— setupUI() / setupConstraints() / bind()
//  - 便于团队统一写法，降低页面搭建心智负担。
//  - 子类只需重写这三个方法；如需主题感知可继承 LWThemedView。
//

import UIKit

open class LWBaseView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        setupUI()
        setupConstraints()
        bind()
    }

    // MARK: - 三段式（子类覆盖）
    /// 1) 添加子视图、基础属性
    open func setupUI() {}
    /// 2) 仅写约束（便于代码审阅与维护）
    open func setupConstraints() {}
    /// 3) 绑定事件/数据/通知
    open func bind() {}

    // MARK: - 工具
    /// 批量添加子视图并禁用自动 autoresizing constraints
    public func lw_addSubview(_ views: UIView...) {
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
