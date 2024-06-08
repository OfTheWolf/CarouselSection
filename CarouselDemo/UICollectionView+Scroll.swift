//
//  UICollectionView+Scroll.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 08/06/2024.
//

import UIKit

extension UICollectionView {
    func findScrollViews() -> [UIScrollView] {
        subviews.compactMap{$0 as? UIScrollView}
    }
}

extension Array where Element == UIScrollView {
    /// Find current horizontal scroll view by comparing current y offsets of collection view with scroll view
    func findScrollView(at offset: CGPoint) -> UIScrollView? {
        guard !isEmpty else { return nil }
        return first { view in
            round(abs(view.contentOffset.y - offset.y)) == .zero
        }
    }
}
