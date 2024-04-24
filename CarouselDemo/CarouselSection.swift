//
//  CarouselSection.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 24/04/2024.
//

import UIKit

struct CarouselSection {
    let collectionView: UICollectionView

    func layoutSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        //2
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .fractionalWidth(0.5)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        //3
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
//            section.interGroupSpacing = 8
        //4
        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            let width = environment.container.contentSize.width //* 0.9 - 8
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - width / 2.0)
                let minScale: CGFloat = 0.9
                let maxScale: CGFloat = minScale + (1.0 - minScale) * exp(-distanceFromCenter / width)
                let scale = max(maxScale, minScale)
                let cell = collectionView.cellForItem(at: item.indexPath)
                item.transform = CGAffineTransform(scaleX: scale, y: scale)
                cell?.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }
        return section
    }
}
