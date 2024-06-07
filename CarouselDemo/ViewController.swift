//
//  ViewController.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 24/04/2024.
//

import UIKit

class ViewController: UIViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

    enum Section: Hashable {
        case list
        case carousel
    }

    struct Item: Hashable {
        let id = UUID()
        let text: String
        let color: UIColor?

        init(text: String, color: UIColor? = nil) {
            self.text = text
            self.color = color
        }
    }

    enum SupplementaryItemKind: String {
        case pager = "pager-dots"
    }

    override func loadView() {
        view = cardView
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: cardView.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        ])
    }

    private lazy var carouselSection: CarouselSection = {
        CarouselSection(collectionView: collectionView)
    }()

    private lazy var layout: UICollectionViewLayout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
        guard let self else { return nil }
        guard let sectionItem = self.dataSource.sectionIdentifier(for: sectionIndex) else { return nil }
        if Section.carousel != sectionItem {
            var conf = UICollectionLayoutListConfiguration.init(appearance: .plain)
            conf.backgroundColor = .clear
            var layoutSection = NSCollectionLayoutSection.list(using: conf, layoutEnvironment: layoutEnvironment)
            layoutSection.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            return layoutSection
        } else {
            return self.carouselSection.layoutSection(for: sectionIndex, layoutEnvironment: layoutEnvironment)
        }
    }

    private lazy var cardView: UIView = {
        let view = UIView()
        view.addSubview(collectionView)
        view.backgroundColor = .init(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)
        return view
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.contentInset = .init(top: 40, left: 0, bottom: 0, right: 0)
        return view
    }()

    private lazy var dataSource: DataSource = {

        let listCellRegistration = UICollectionView.CellRegistration<ListItemCell, Item> { cell, indexPath, itemIdentifier in
            cell.configure(with: itemIdentifier.text)
        }

        let carouselCellRegistration = UICollectionView.CellRegistration<CarouselItemCell, Item> { cell, indexPath, itemIdentifier in
            cell.configure(with: itemIdentifier.text, backgroundColor: itemIdentifier.color)
        }

        let pagerRegistration = UICollectionView.SupplementaryRegistration<PagerDotsView>(elementKind: SupplementaryItemKind.pager.rawValue) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self else { return }
            guard let section = self.dataSource.sectionIdentifier(for: indexPath.section) else { return }
            let numberOfPages = self.dataSource.snapshot().numberOfItems(inSection: section)
            let model = PagerDotsView.Model(numberOfPages: numberOfPages,
                                            pageIndicatorTintColor: nil,
                                            currentPageIndicatorTintColor: nil) { currentPage in
                self.didPageChange(currentPage, at: indexPath.section)
            }
            supplementaryView.configure(with: model)
            carouselSection.setPageControl(supplementaryView.pageControl)
        }

        let dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return nil }
            guard let section = self.dataSource.sectionIdentifier(for: indexPath.section) else { return nil }
            return switch section {
            case .list:
                collectionView.dequeueConfiguredReusableCell(using: listCellRegistration, for: indexPath, item: itemIdentifier)
            case .carousel:
                collectionView.dequeueConfiguredReusableCell(using: carouselCellRegistration, for: indexPath, item: itemIdentifier)
            }
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard let kind = SupplementaryItemKind(rawValue: kind) else { return nil }
            return switch kind {
            case .pager:
                collectionView.dequeueConfiguredReusableSupplementary(using: pagerRegistration, for: indexPath)
            }
        }
        return dataSource
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        var snap = NSDiffableDataSourceSnapshot<Section, Item>()
        snap.appendSections([.carousel, .list])
        var items = (0..<5).map(\.description).map{Item(text: $0, color: .random)}
        items.insert(Item(text: "4", color: items[4].color), at: 0)
        items.append(Item(text: "0", color: items[1].color))
        snap.appendItems(items, toSection: .carousel)
        let others = (10..<30).map(\.description)
        others.enumerated().forEach { index, item in
            snap.appendItems([
                Item(text: item)
            ], toSection: .list)
        }
        dataSource.apply(snap)
    }

    private func didPageChange(_ currentPage: Int, at section: Int) {
        let indexPath = IndexPath(item: currentPage, section: section)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        carouselSection.applyTransform(to: cell, at: indexPath)
    }
}
