//
//  HomeTableViewCell.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import UIKit

class HomeTableViewCell: UITableViewCell {
    
    static let identifier = "HomeTableViewCell"
    
    private lazy var imageViewPhoto: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = .zero
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.estimatedItemSize = CGSize(width: 50.0, height: 25.0)
        return layout
    }()
    
    private lazy var typesCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, 
                                    collectionViewLayout: collectionViewLayout)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.clipsToBounds = false
        view.register(TypeCollectionViewCell.self,
                      forCellWithReuseIdentifier: TypeCollectionViewCell.identifier)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = nil
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: 20.0)
        label.accessibilityIdentifier = "cellTitleLabel"
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = nil
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.textColor = .gray
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            self.titleLabel,
            self.typesCollectionView,
            self.descriptionLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    var pokemon: Pokemon? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(imageViewPhoto)
        self.addSubview(stackView)

        NSLayoutConstraint.activate([
            imageViewPhoto.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16.0),
            imageViewPhoto.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageViewPhoto.widthAnchor.constraint(equalTo: imageViewPhoto.heightAnchor, multiplier: 1.0),
            imageViewPhoto.widthAnchor.constraint(equalToConstant: 80.0),

            titleLabel.heightAnchor.constraint(equalToConstant: 25.0),
            typesCollectionView.heightAnchor.constraint(equalToConstant: 30.0),
            
            stackView.leadingAnchor.constraint(equalTo: imageViewPhoto.trailingAnchor, constant: 16.0),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8.0),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8.0),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8.0)

        ])

    }
    
    private func updateView() {
        if let imageURL = self.pokemon?.detail?.officialArtworkImageURL {
            imageViewPhoto.downloaded(from: imageURL)
        }else {
            imageViewPhoto.image = UIImage(systemName: "photo.artframe.circle.fill")
        }
        titleLabel.text = pokemon?.name.capitalized
        // TODO: implement the description
        /// Maybe you need to call another API.
        descriptionLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam id orci et nunc varius laoreet. Curabitur pharetra mi sapien, facilisis accumsan neque pharetra non. Etiam accumsan tortor id risus aliquam, ut faucibus eros hendrerit. Suspendisse id interdum sapien, id vehicula sem. Sed eget malesuada ante, id blandit lacus. Aliquam blandit est sit amet metus volutpat, eget malesuada elit convallis. Mauris luctus magna sed metus ultrices, vel tincidunt quam hendrerit. Integer cursus, sem sed ultricies rhoncus, eros tortor pulvinar ex, eget suscipit arcu nunc ac risus."
        
        typesCollectionView.reloadData()
    }
}

// MARK: - UICollectionView protocols conformances

extension HomeTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pokemon?.detail?.types.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TypeCollectionViewCell.identifier,
                                                      for: indexPath) as! TypeCollectionViewCell
        let type = pokemon?.detail?.types[indexPath.row]
        cell.update(text: type?.type.name ?? "")
        return cell
    }
}

extension HomeTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: didSelectItemAt
    }
}

extension HomeTableViewCell: StaticIdentifiable { }
