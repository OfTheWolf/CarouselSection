//
//  PagerDotsView.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 28/04/2024.
//

import UIKit

final class PagerDotsView: UICollectionReusableView {

    typealias PageBlock = (Int) -> Void

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(pageControl)
        setupConstraints()
        pageControl.addTarget(self, action: #selector(tapAction), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Internals

    lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var didChangePage: (PageBlock)?

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: topAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor),
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    @objc private func tapAction(_ sender: UIPageControl) {
        didChangePage?(sender.currentPage + 1)
    }

    // MARK: - Public Actions

    func configure(with model: Model) {
        pageControl.numberOfPages = model.numberOfPages
        pageControl.currentPageIndicatorTintColor = model.currentPageIndicatorTintColor
        pageControl.pageIndicatorTintColor = model.pageIndicatorTintColor
        didChangePage = model.didPageChange
    }

    func update(currentPage: Int) {
        pageControl.currentPage = currentPage
    }

//    MARK: - Model

    struct Model {
        let numberOfPages: Int
        let pageIndicatorTintColor: UIColor?
        let currentPageIndicatorTintColor: UIColor?
        let didPageChange: PageBlock?
    }
}
