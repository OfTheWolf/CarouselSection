//
//  ListItemCell.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 28/04/2024.
//

import UIKit

final class ListItemCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .headline)
        view.textAlignment = .center
        return view
    }()

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    func configure(with text: String) {
        label.text = text
    }
}
