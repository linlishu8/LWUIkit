//
//  LWCompositionalLayoutBuilder.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：构建常见的 Compositional Layout（列表/网格/“瀑布”）。
//  - 提供可配 spacing / insets / header & footer / 横向分页模式 等。
//

import UIKit

public enum LWCompositionalLayoutBuilder {

    // MARK: - 列表（基于 iOS14 UICollectionLayoutListConfiguration）
    public static func list(appearance: UICollectionLayoutListConfiguration.Appearance = .plain,
                            showsSeparators: Bool = true,
                            headerMode: UICollectionLayoutListConfiguration.HeaderMode = .none,
                            footerMode: UICollectionLayoutListConfiguration.FooterMode = .none) -> UICollectionViewCompositionalLayout {
        var config = UICollectionLayoutListConfiguration(appearance: appearance)
        config.showsSeparators = showsSeparators
        config.headerMode = headerMode
        config.footerMode = footerMode
        return UICollectionViewCompositionalLayout.list(using: config)
    }

    // MARK: - 网格（等宽 N 列，高度可固定或估算）
    public static func grid(columns: Int,
                            itemHeight: NSCollectionLayoutDimension = .estimated(120),
                            interItem: CGFloat = 8,
                            interGroup: CGFloat = 8,
                            contentInsets: NSDirectionalEdgeInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8),
                            orthogonalScrolling: UICollectionLayoutSectionOrthogonalScrollingBehavior = .none,
                            hasHeader: Bool = false,
                            hasFooter: Bool = false) -> UICollectionViewCompositionalLayout {
        let fraction = 1.0 / CGFloat(max(1, columns))
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fraction), heightDimension: itemHeight)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: interItem/2, leading: interItem/2, bottom: interItem/2, trailing: interItem/2)

        let groupHeight = itemHeight
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInsets
        section.interGroupSpacing = interGroup
        section.orthogonalScrollingBehavior = orthogonalScrolling

        if hasHeader { section.boundarySupplementaryItems.append(makeHeader()) }
        if hasFooter { section.boundarySupplementaryItems.append(makeFooter()) }

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - “瀑布风”两列（估算高度，不严格 Masonry，仅简化版本）
    public static func waterfallTwoColumn(interItem: CGFloat = 8,
                                          interGroup: CGFloat = 8,
                                          contentInsets: NSDirectionalEdgeInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8),
                                          hasHeader: Bool = false,
                                          hasFooter: Bool = false) -> UICollectionViewCompositionalLayout {
        // 通过 estimated 高度 + 两列分组模拟；真实 Masonry 建议自定义 Layout。
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(200))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: interItem/2, leading: interItem/2, bottom: interItem/2, trailing: interItem/2)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = contentInsets
        section.interGroupSpacing = interGroup

        if hasHeader { section.boundarySupplementaryItems.append(makeHeader()) }
        if hasFooter { section.boundarySupplementaryItems.append(makeFooter()) }

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Supplementary
    private static func makeHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44)),
              elementKind: UICollectionView.elementKindSectionHeader,
              alignment: .top)
    }
    private static func makeFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(28)),
              elementKind: UICollectionView.elementKindSectionFooter,
              alignment: .bottom)
    }
}
