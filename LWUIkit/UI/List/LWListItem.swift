//
//  LWListItem.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：定义可 Diff 的列表模型协议（Section / Item）。
//  - 统一要求：`id` 唯一、`Hashable`，方便做 Diffable Snapshot。
//  - 提供通用包装类型（AnyListSection / AnyListItem），用于简单场景快速上手。
//

import UIKit

/// 列表分组模型协议（可 Diff）
public protocol LWListSection: Hashable, Identifiable where ID: Hashable {
    var id: ID { get }                         // 唯一标识
    var headerTitle: String? { get }           // 可选标题（也可用补充视图）
    var footerTitle: String? { get }
}

/// 列表条目模型协议（可 Diff）
public protocol LWListItem: Hashable, Identifiable where ID: Hashable {
    var id: ID { get }                         // 唯一标识
    /// 用于 UI 列表的通用文案（若走自绘 Cell 可忽略）
    var title: String? { get }
    var subtitle: String? { get }
    var image: UIImage? { get }
}

/// 通用 Section 包装（轻量使用场景）
public struct LWAnyListSection: LWListSection {
    public let id: String
    public var headerTitle: String?
    public var footerTitle: String?
    public init(id: String, headerTitle: String? = nil, footerTitle: String? = nil) {
        self.id = id; self.headerTitle = headerTitle; self.footerTitle = footerTitle
    }
}

/// 通用 Item 包装（轻量使用场景）
public struct LWAnyListItem: LWListItem {
    public let id: String
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public init(id: String, title: String? = nil, subtitle: String? = nil, image: UIImage? = nil) {
        self.id = id; self.title = title; self.subtitle = subtitle; self.image = image
    }
}
