// ASCollectionView. Created by Apptek Studios 2019

import Foundation
import SwiftUI

@available(iOS 13.0, *)
public struct ASCollectionViewStaticContent: Identifiable
{
	public var index: Int
	var view: AnyView

	public var id: Int { index }
}

@available(iOS 13.0, *)
public struct ASCollectionViewItemUniqueID: Hashable
{
	var sectionIDHash: Int
	var itemIDHash: Int
	init<SectionID: Hashable, ItemID: Hashable>(sectionID: SectionID, itemID: ItemID)
	{
		sectionIDHash = sectionID.hashValue
		itemIDHash = itemID.hashValue
	}
}

@available(iOS 13.0, *)
public typealias ASCollectionViewSection = ASSection

@available(iOS 13.0, *)
public struct ASSection<SectionID: Hashable>
{
	public var id: SectionID

	internal var dataSource: ASSectionDataSourceProtocol

	public var itemIDs: [ASCollectionViewItemUniqueID]
	{
		dataSource.getUniqueItemIDs(withSectionID: id)
	}

	var shouldCacheCells: Bool = false

	// Only relevant for ASTableView
	var disableDefaultTheming: Bool = false
	var tableViewSeparatorInsets: UIEdgeInsets?
	var estimatedHeaderHeight: CGFloat?
	var estimatedFooterHeight: CGFloat?
}

@available(iOS 13.0, *)
public struct Selection<Data> {
	public let items: [(Int, Data)]

	/// `item` is guaranteed to exist because empty selection is modeled by a `nil` `Selection` in
	/// `ASSection`.
	public var item: (Int, Data) { items[0] }
}

@available(iOS 13.0, *)
extension Selection: Equatable where Data: Equatable {
	public static func == (lhs: Selection<Data>, rhs: Selection<Data>) -> Bool {
		zip(lhs.items, rhs.items).reduce(true) { (isEqual: Bool, elements: ((Int, Data), (Int, Data))) -> Bool in
			guard isEqual else { return false }
			let (left, right) = elements
			return left.0 == right.0 && left.1 == right.1
		}
	}
}

@available(iOS 13.0, *)
extension Selection: Hashable where Data: Hashable {
	public func hash(into hasher: inout Hasher) {
		items.forEach { (index: Int, data: Data) in
			hasher.combine(index)
			hasher.combine(data)
		}
	}
}

// MARK: SUPPLEMENTARY VIEWS - INTERNAL

@available(iOS 13.0, *)
internal extension ASCollectionViewSection
{
	mutating func setHeaderView<Content: View>(_ view: Content?)
	{
		setSupplementaryView(view, ofKind: UICollectionView.elementKindSectionHeader)
	}

	mutating func setFooterView<Content: View>(_ view: Content?)
	{
		setSupplementaryView(view, ofKind: UICollectionView.elementKindSectionFooter)
	}

	mutating func setSupplementaryView<Content: View>(_ view: Content?, ofKind kind: String)
	{
		guard let view = view else
		{
			dataSource.supplementaryViews.removeValue(forKey: kind)
			return
		}

		dataSource.supplementaryViews[kind] = AnyView(view)
	}

	var supplementaryKinds: Set<String>
	{
		Set(dataSource.supplementaryViews.keys)
	}

	func supplementary(ofKind kind: String) -> AnyView?
	{
		dataSource.supplementaryViews[kind]
	}
}
