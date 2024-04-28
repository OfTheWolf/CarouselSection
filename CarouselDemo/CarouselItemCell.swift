//
//  CarouselItemCell.swift
//  CarouselDemo
//
//  Created by Ugur Bozkurt on 28/04/2024.
//

import UIKit

final class CarouselItemCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 16
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
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        ])
    }

    func configure(with text: String, backgroundColor: UIColor?) {
        label.text = text
        contentView.backgroundColor = backgroundColor
    }
}
