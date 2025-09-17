//
//  LWCellRegistrations.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：封装 UIListContentConfiguration / UIContentConfiguration 以及 CellRegistration，
//  - 极大减少 Cell 模板代码。
//  - 同时支持 UITableView / UICollectionView。
//

import UIKit

// MARK: - 轻量注册类型：Table
public struct LWTableCellRegistration<Cell: UITableViewCell, Item> {
    public let configure: (Cell, IndexPath, Item) -> Void
    public init(configure: @escaping (Cell, IndexPath, Item) -> Void) {
        self.configure = configure
    }
}

public extension UITableView {
    /// 按需注册 + 出队 + 配置
    func lw_dequeueConfiguredReusableCell<Cell: UITableViewCell, Item>(
        using reg: LWTableCellRegistration<Cell, Item>,
        for indexPath: IndexPath,
        item: Item,
        reuseIdentifier: String = String(describing: Cell.self)
    ) -> Cell {
        // 按需注册（避免未注册崩溃）
        if dequeueReusableCell(withIdentifier: reuseIdentifier) == nil {
            register(Cell.self, forCellReuseIdentifier: reuseIdentifier)
        }
        guard let cell = dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("无法出队：\(Cell.self)")
        }
        reg.configure(cell, indexPath, item)
        return cell
    }
}

// MARK: - 轻量注册类型：Collection
public struct LWCollectionCellRegistration<Cell: UICollectionViewCell, Item> {
    public let configure: (Cell, IndexPath, Item) -> Void
    public init(configure: @escaping (Cell, IndexPath, Item) -> Void) {
        self.configure = configure
    }
}

public extension UICollectionView {
    func lw_dequeueConfiguredReusableCell<Cell: UICollectionViewCell, Item>(
        using reg: LWCollectionCellRegistration<Cell, Item>,
        for indexPath: IndexPath,
        item: Item,
        reuseIdentifier: String = String(describing: Cell.self)
    ) -> Cell {
        if dataSource == nil {
            // 确保已注册在使用方进行，若未注册则尝试注册
            register(Cell.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
        guard let cell = dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("无法出队：\(Cell.self)")
        }
        reg.configure(cell, indexPath, item)
        return cell
    }
}

// MARK: - Table 快捷注册器
public enum LWTableCellReg {
    /// 标准样式（UIListContentConfiguration）
    public static func standard<Item>(_ update: @escaping (UITableViewCell, Item) -> Void)
    -> LWTableCellRegistration<UITableViewCell, Item> {
        .init { cell, _, item in
            var content = UIListContentConfiguration.cell()
            // 兼容 Swift 未来模式：将协议作为类型使用时需写 `any` 前缀
            if let listItem = item as? any LWListItem {
                content.text = listItem.title
                content.secondaryText = listItem.subtitle
                content.image = listItem.image
            }
            content.textProperties.font = LWTypography.body.font()
            content.secondaryTextProperties.color = LWSemanticColors.textSecondary
            cell.contentConfiguration = content
            update(cell, item)
        }
    }

    /// 完全自定义 UIContentConfiguration
    public static func custom<Item, C: UIContentConfiguration>(
        makeConfig: @escaping (Item) -> C,
        then: ((UITableViewCell, Item) -> Void)? = nil
    ) -> LWTableCellRegistration<UITableViewCell, Item> {
        .init { cell, _, item in
            cell.contentConfiguration = makeConfig(item)
            then?(cell, item)
        }
    }
}

// MARK: - Collection 快捷注册器
public enum LWCollectionCellReg {
    /// 列表外观的标准样式（UICollectionViewListCell）
    public static func listStandard<Item>(_ update: @escaping (UICollectionViewListCell, Item) -> Void)
    -> LWCollectionCellRegistration<UICollectionViewListCell, Item> {
        .init { cell, _, item in
            var content = UIListContentConfiguration.cell()
            if let listItem = item as? any LWListItem {
                content.text = listItem.title
                content.secondaryText = listItem.subtitle
                content.image = listItem.image
            }
            cell.contentConfiguration = content
            update(cell, item)
        }
    }

    /// 通用样式：自定义 Cell
    public static func anyCell<Cell: UICollectionViewCell, Item>(_ update: @escaping (Cell, Item) -> Void)
    -> LWCollectionCellRegistration<Cell, Item> {
        .init { cell, _, item in update(cell, item) }
    }
}
