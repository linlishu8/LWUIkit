//
//  LWDiffableCollection.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：对 UITableViewDiffableDataSource / UICollectionViewDiffableDataSource 做泛型封装。
//  - 简化 Snapshot 更新（append/replace/reconfigure）。
//  - 提供安全的 item(at:) / sectionIdentifier(for:)。
//

import UIKit

// MARK: - 集合封装
public final class LWDiffableCollection<Section: Hashable, Item: Hashable> {
    public typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    public typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Item>

    public let collectionView: UICollectionView
    public let dataSource: DataSource

    public init(collectionView: UICollectionView,
                cellProvider: @escaping DataSource.CellProvider) {
        self.collectionView = collectionView
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: cellProvider)
        self.collectionView.dataSource = dataSource
    }

    public func apply(sections: [Section], itemsForSection: (Section) -> [Item], animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        var snap = Snapshot()
        snap.appendSections(sections)
        for s in sections { snap.appendItems(itemsForSection(s), toSection: s) }
        dataSource.apply(snap, animatingDifferences: animatingDifferences, completion: completion)
    }

    public func apply(items: [Item], to section: Section, animatingDifferences: Bool = true, completion: (() -> Void)? = nil) {
        var snap = dataSource.snapshot()
        if !snap.sectionIdentifiers.contains(section) {
            snap.appendSections([section])
        } else {
            let current = snap.itemIdentifiers(inSection: section)
            snap.deleteItems(current)
        }
        snap.appendItems(items, toSection: section)
        dataSource.apply(snap, animatingDifferences: animatingDifferences, completion: completion)
    }

    public func reconfigure(items: [Item]) {
        if #available(iOS 15.0, *) {
            var snap = dataSource.snapshot()
            snap.reconfigureItems(items)
            dataSource.apply(snap, animatingDifferences: true)
        } else {
            collectionView.reloadData()
        }
    }

    public func item(at indexPath: IndexPath) -> Item? { dataSource.itemIdentifier(for: indexPath) }
    public func indexPath(for item: Item) -> IndexPath? { dataSource.indexPath(for: item) }
    public func sectionIdentifier(for index: Int) -> Section? {
        let ids = dataSource.snapshot().sectionIdentifiers
        return (index >= 0 && index < ids.count) ? ids[index] : nil
    }
}
