//
//  CarouselSection.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 24/04/2024.
//

import UIKit

final class CarouselSection {
    private weak var collectionView: UICollectionView?
    private weak var pageControl: UIPageControl?
    private var scales: [IndexPath: CGFloat]

    private let itemScale: CGFloat = 0.9 /// cell item width scale

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.scales = [:]
    }

    func setPageControl(_ pageControl: UIPageControl?) {
        self.pageControl = pageControl
    }

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
            let width = environment.container.effectiveContentSize.width
            let itemWidth = width * itemScale
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
            let centerOffset = abs(xOffset/itemWidth - nearestIndex)
            updatePageControl(with: currentPage)
            if centerOffset < 0.05 {
                let count = collectionView?.numberOfItems(inSection: sectionIndex) ?? 0
                if currentPage == count - 1 {
                    collectionView?.scrollToItem(at: .init(item: 1, section: sectionIndex), at: .centeredHorizontally, animated: false)
                } else if currentPage == 0 {
                    collectionView?.scrollToItem(at: .init(item: count - 2, section: sectionIndex), at: .centeredHorizontally, animated: false)
                }
            }
        }
        return section
    }

    func applyTransform(to cell: UIView, at indexPath: IndexPath) {
        guard let scale = scales[indexPath] else { return }
        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    private func updatePageControl(with page: Int) {
        let isInteracting = pageControl?.isInteracting ?? false
        if !isInteracting {
            pageControl?.currentPage = page
        }
    }
}
