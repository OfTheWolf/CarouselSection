//
//  ViewController.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 24/04/2024.
//

import UIKit

class ViewController: UIViewController {

    enum Section: Hashable {
        case list(Int)
        case carousel
    }

    struct Item: Hashable {
        let text: String
    }

    override func loadView() {
        view = collectionView
    }

    private lazy var carouselSection: CarouselSection = {
        CarouselSection(collectionView: collectionView)
    }()

    private lazy var layout: UICollectionViewLayout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
        guard let self else { return nil }
        let sectionItem = self.dataSource.sectionIdentifier(for: sectionIndex)!
        if Section.carousel != sectionItem {
            var conf = UICollectionLayoutListConfiguration.init(appearance: .plain)
            conf.backgroundColor = .clear
            var layoutSection = NSCollectionLayoutSection.list(using: conf, layoutEnvironment: layoutEnvironment)
            layoutSection.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            return layoutSection
        } else {
            return self.carouselSection.layoutSection()
        }
    }

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .lightGray
        return view
    }()

    private let cellReg = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, itemIdentifier in
        var content = cell.defaultContentConfiguration()
        content.text = itemIdentifier.text
        content.textProperties.alignment = .center
        cell.contentConfiguration = content
    }

    private lazy var dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
        collectionView.dequeueConfiguredReusableCell(using: self.cellReg, for: indexPath, item: itemIdentifier)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var snap = NSDiffableDataSourceSnapshot<Section, Item>()
        snap.appendSections([.list(0), .carousel, .list(1)])
        let items = (0..<10).map(\.description)
        items.enumerated().forEach { index, item in
            snap.appendItems([
                Item(text: item)
            ], toSection: index < 5 ? .list(0) : .carousel)
        }
        let others = (10..<15).map(\.description)
        others.enumerated().forEach { index, item in
            snap.appendItems([
                Item(text: item)
            ], toSection: .list(1))
        }
        dataSource.apply(snap)

    }


}

