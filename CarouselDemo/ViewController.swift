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
        case carousel(Int)
    }

    struct Item: Hashable {
        let id: Int
        let text: String
        let color: UIColor?
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

    private var didSetInitialCarouselOffsets = false

    private var carouselSections: [Section: CarouselSection] = [:]

    private lazy var layout: UICollectionViewLayout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, layoutEnvironment in
        guard let self else { return nil }
        guard let sectionItem = self.dataSource.sectionIdentifier(for: sectionIndex) else { return nil }
        if Section.list == sectionItem {
            var conf = UICollectionLayoutListConfiguration.init(appearance: .plain)
            conf.backgroundColor = .clear
            var layoutSection = NSCollectionLayoutSection.list(using: conf, layoutEnvironment: layoutEnvironment)
            layoutSection.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)
            return layoutSection
        } else {
            let carouselSection = CarouselSection(collectionView: collectionView)
            carouselSections[sectionItem] = carouselSection
            carouselSection.didUpdatePage = { page in
                self.pagerDots[sectionItem]?.update(currentPage: page)
            }
            return carouselSection.layoutSection(for: sectionIndex, layoutEnvironment: layoutEnvironment)
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

    private var pagerDots: [Section: PagerDotsView] = [:]

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
            let model = PagerDotsView.Model(numberOfPages: numberOfPages - 2,
                                            pageIndicatorTintColor: nil,
                                            currentPageIndicatorTintColor: nil) { currentPage in
                self.didPageChange(currentPage, at: indexPath.section)
            }
            supplementaryView.configure(with: model)
            pagerDots[section] = supplementaryView
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

        let refresh = UIBarButtonItem(systemItem: .refresh, primaryAction: UIAction(handler: {[unowned self] _ in
            reloadData()
        }))

        let insert = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: {[unowned self] _ in
            var snap = dataSource.snapshot()
            snap.appendSections([.carousel(10)])
            snap.appendItems(makeCarouselItems(from: 30, to: 40))
            dataSource.apply(snap) { [unowned self] in
                adjustOffsets()
            }
        }))

        navigationItem.rightBarButtonItems = [refresh, insert]

        reloadData()
    }

    private func makeCarouselItems(from start: Int, to end: Int) -> [Item] {
        var items = (0..<(end-start)).map(\.description).enumerated().map{Item(id: $0+start, text: $1, color: nil)}
        let count = end - start
        let last = items[count-1]
        let first = items[0]
        items.insert(Item(id: end, text: last.text, color: last.color), at: 0)
        items.append(Item(id: end+1, text: first.text, color: first.color))
        return items
    }

    private func reloadData() {
        var snap = NSDiffableDataSourceSnapshot<Section, Item>()
        snap.appendSections([.carousel(0)])
        snap.appendItems(makeCarouselItems(from: 0, to: 5))
        snap.appendSections([.carousel(1)])
        snap.appendItems(makeCarouselItems(from: 5, to: 10))
        snap.appendSections([.carousel(2)])
        snap.appendItems(makeCarouselItems(from: 10, to: 15))
        snap.appendSections([.list])
        let others = (10..<30).map(\.description)
        others.enumerated().forEach { index, item in
            snap.appendItems([
                Item(id: index, text: item, color: nil)
            ], toSection: .list)
        }
        dataSource.apply(snap) { [unowned self] in
            adjustOffsets()
        }
    }

    private func adjustOffsets() {
        carouselSections.forEach { key, carouselSection in
            guard let index = dataSource.index(for: key) else { return }
            self.collectionView.scrollToItem(at: .init(item: 1, section: index), at: .centeredHorizontally, animated: false)
        }
    }

    private func didPageChange(_ currentPage: Int, at section: Int) {
        let indexPath = IndexPath(item: currentPage, section: section)
        collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
    }

}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let section = dataSource.sectionIdentifier(for: indexPath.section) else { return }
        carouselSections[section]?.applyTransform(to: cell, at: indexPath)
    }
}
