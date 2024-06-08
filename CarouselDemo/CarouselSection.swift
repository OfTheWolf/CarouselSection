//
//  CarouselSection.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 24/04/2024.
//

import UIKit

final class CarouselSection {
    private weak var collectionView: UICollectionView?
    private var scales: [IndexPath: CGFloat]

    private let itemScale: CGFloat = 0.9 /// cell item width scale

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.scales = [:]
    }

    var didUpdatePage: ((Int) -> Void)?

    func layoutSection(for sectionIndex: Int, layoutEnvironment: any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(itemScale),
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        let pagerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(24))
        let kind = ViewController.SupplementaryItemKind.pager.rawValue
        let pagerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: pagerSize, elementKind: kind, alignment: .bottom)
        section.boundarySupplementaryItems = [pagerItem]
        section.visibleItemsInvalidationHandler = { [weak self] (visibleItems, offset, environment) in
            guard let self else { return }
            let items = visibleItems.filter { $0.representedElementKind == nil} /// Filter supplementary views out
            guard !items.isEmpty else { return }
            let width = environment.container.effectiveContentSize.width
            let itemWidth = items[0].frame.width
            let itemOffset = (width - itemWidth) / 2
            let xOffset = offset.x + itemOffset
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - width / 2.0)
                let minScale: CGFloat = 0.9
                let scale: CGFloat = minScale + (1.0 - minScale) * exp(-distanceFromCenter / (itemWidth / 2))
                self.scales[item.indexPath] = scale
                guard let cell = self.collectionView?.cellForItem(at: item.indexPath) else { return }
                self.applyTransform(to: cell, at: item.indexPath)
            }
            let nearestIndex = (xOffset / itemWidth).rounded()
            let currentPage = Int(nearestIndex)
            didUpdatePage?(currentPage - 1)
            let count = collectionView?.numberOfItems(inSection: sectionIndex) ?? 0
            guard let scrollViews = self.collectionView?.findScrollViews() else {
                return
            }
            guard let scrollView = scrollViews.findScrollView(at: offset) else {
                return }
            if currentPage == count - 1 {
                scrollView.contentOffset = .init(x: offset.x - itemWidth*CGFloat(count-2), y: offset.y)
            } else if currentPage == 0 {
                scrollView.contentOffset = .init(x: offset.x + itemWidth*CGFloat(count-2), y: offset.y)
            }
        }
        return section
    }

    func applyTransform(to cell: UIView, at indexPath: IndexPath) {
        guard let scale = scales[indexPath] else { return }
        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
