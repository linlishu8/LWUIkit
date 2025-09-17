//
//  LWReusable.swift
//  LWUIkit
//
//  Created by June on 2025/9/17.
//
//  职责：提供通用的 register/dequeue 泛型封装，消除字符串标识错误。
//

import UIKit

public protocol LWReusable: AnyObject {
    static var lw_reuseIdentifier: String { get }
}
public extension LWReusable {
    static var lw_reuseIdentifier: String { String(describing: Self.self) }
}

public protocol LWNibLoadable: AnyObject {
    static var lw_nib: UINib { get }
}
public extension LWNibLoadable where Self: UIView {
    static var lw_nib: UINib { UINib(nibName: String(describing: Self.self), bundle: .main) }
}

// MARK: - UITableView
public extension UITableView {
    func lw_register<Cell: UITableViewCell>(_ cell: Cell.Type, useNib: Bool = false) where Cell: LWReusable {
        if useNib, let _ = Bundle.main.path(forResource: Cell.lw_reuseIdentifier, ofType: "nib") {
            register(UINib(nibName: Cell.lw_reuseIdentifier, bundle: .main), forCellReuseIdentifier: Cell.lw_reuseIdentifier)
        } else {
            register(Cell.self, forCellReuseIdentifier: Cell.lw_reuseIdentifier)
        }
    }
    func lw_dequeue<Cell: UITableViewCell>(_ cell: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: LWReusable {
        guard let c = dequeueReusableCell(withIdentifier: Cell.lw_reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("未注册 \(Cell.self)")
        }
        return c
    }

    func lw_registerHeaderFooter<View: UITableViewHeaderFooterView>(_ view: View.Type, useNib: Bool = false) where View: LWReusable {
        if useNib, let _ = Bundle.main.path(forResource: View.lw_reuseIdentifier, ofType: "nib") {
            register(UINib(nibName: View.lw_reuseIdentifier, bundle: .main), forHeaderFooterViewReuseIdentifier: View.lw_reuseIdentifier)
        } else {
            register(View.self, forHeaderFooterViewReuseIdentifier: View.lw_reuseIdentifier)
        }
    }
    func lw_dequeueHeaderFooter<View: UITableViewHeaderFooterView>(_ view: View.Type) -> View? where View: LWReusable {
        dequeueReusableHeaderFooterView(withIdentifier: View.lw_reuseIdentifier) as? View
    }
}

// MARK: - UICollectionView
public extension UICollectionView {
    func lw_register<Cell: UICollectionViewCell>(_ cell: Cell.Type, useNib: Bool = false) where Cell: LWReusable {
        if useNib, let _ = Bundle.main.path(forResource: Cell.lw_reuseIdentifier, ofType: "nib") {
            register(UINib(nibName: Cell.lw_reuseIdentifier, bundle: .main), forCellWithReuseIdentifier: Cell.lw_reuseIdentifier)
        } else {
            register(Cell.self, forCellWithReuseIdentifier: Cell.lw_reuseIdentifier)
        }
    }
    func lw_dequeue<Cell: UICollectionViewCell>(_ cell: Cell.Type, for indexPath: IndexPath) -> Cell where Cell: LWReusable {
        guard let c = dequeueReusableCell(withReuseIdentifier: Cell.lw_reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("未注册 \(Cell.self)")
        }
        return c
    }

    func lw_registerSupplementary<View: UICollectionReusableView>(_ view: View.Type, ofKind kind: String, useNib: Bool = false) where View: LWReusable {
        if useNib, let _ = Bundle.main.path(forResource: View.lw_reuseIdentifier, ofType: "nib") {
            register(UINib(nibName: View.lw_reuseIdentifier, bundle: .main), forSupplementaryViewOfKind: kind, withReuseIdentifier: View.lw_reuseIdentifier)
        } else {
            register(View.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: View.lw_reuseIdentifier)
        }
    }
    func lw_dequeueSupplementary<View: UICollectionReusableView>(_ view: View.Type, ofKind kind: String, for indexPath: IndexPath) -> View where View: LWReusable {
        guard let v = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: View.lw_reuseIdentifier, for: indexPath) as? View else {
            fatalError("未注册 \(View.self)")
        }
        return v
    }
}
