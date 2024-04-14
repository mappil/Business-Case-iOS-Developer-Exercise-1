//
//  TypeCollectionViewCell.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 14/04/24.
//

import UIKit

class TypeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "TypeCollectionViewCell"

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = nil
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.textColor = .gray
        return label
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray5
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        self.addSubview(containerView)
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 6.0),
            titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -6.0),
            titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 2.0),
            titleLabel.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -2.0)

        ])
    }
    
    func update(text: String) {
        titleLabel.text = text.capitalized
    }
    
}
