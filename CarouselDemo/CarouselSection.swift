//
//  CarouselSection.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 24/04/2024.
//

import UIKit

final class CarouselSection {
    private let collectionView: UICollectionView
    private var pageControl: UIPageControl?
    private var scales: [IndexPath: CGFloat]

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.scales = [:]
    }

    func hookPageControl(_ pageControl: UIPageControl?) {
        self.pageControl = pageControl
    }

    func layoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
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
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - width / 2.0)
                let minScale: CGFloat = 0.9
                let maxScale: CGFloat = minScale + (1.0 - minScale) * exp(-distanceFromCenter / width)
                let scale = max(maxScale, minScale)
                self.scales[item.indexPath] = scale
                guard let cell = self.collectionView.cellForItem(at: item.indexPath) else { return }
                cell.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
//            let xfactor = offset.x / width
//            let xfactorRounded = round(xfactor)
//            let page = Int(max(0, xfactorRounded))
//            pageControl?.currentPage = page
        }
        return section
    }

    func applyTransform(to cell: UIView, at indexPath: IndexPath) {
        guard let scale = scales[indexPath] else { return }
        cell.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
