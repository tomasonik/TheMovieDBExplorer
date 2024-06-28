//
//  MovieListCollectionViewCell.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import UIKit
import SDWebImage

final class MoviesListCollectionViewCell: UICollectionViewCell, Configurable {
    
    enum Constant {
        static let favouritingButtonSize: CGFloat = 44
        static let titleInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private lazy var favouritingButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: Constant.favouritingButtonSize).activate()
        button.heightAnchor.constraint(equalToConstant: Constant.favouritingButtonSize).activate()
        button.addTarget(self, action: #selector(favoriteButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = .max
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var viewModel: MovieItemViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: MovieItemViewModel) {
        self.viewModel = viewModel
        
        titleLabel.text = viewModel.title
        imageView.sd_setImage(with: viewModel.imageUrl)
        
        let buttonImage = FavouritingConstant.tooglingIcon(isFavourite: viewModel.isFavourite)
        favouritingButton.setImage(buttonImage, for: .normal)
    }
    
    // MARK: -
    
    private func setUpView() {
        contentView.addSubview(titleLabel)
        titleLabel.fill(view: contentView, edges: Constant.titleInsets)

        contentView.addSubview(imageView)
        imageView.fill(view: contentView)
        
        contentView.addSubview(favouritingButton)
        favouritingButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).activate()
        favouritingButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).activate()

        backgroundColor = .darkGray
    }
    
    @objc private func favoriteButtonAction() {
        viewModel?.toogleFavourite()
    }
    
}
