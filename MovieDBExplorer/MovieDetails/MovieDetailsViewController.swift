//
//  MovieDetailsViewController.swift
//  MovieDBExplorer
//
//  Created by Tomek on 26/06/2024.
//

import Foundation
import UIKit
import Combine
import SDWebImage

final class MovieDetailsViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var mainStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(loadingIndicator)
        stackView.addArrangedSubview(detailsStackView)
        return stackView
    }()
    
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        return stackView
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    private let viewModel: MovieDetailsViewModel
    private var cancellable = [AnyCancellable]()
    
    init(viewModel: MovieDetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(mainStackView)
        configureConstraints()
    }
 
    override func viewDidLoad() {
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }
    
    // MARK: -
    
    private func configureConstraints() {
        mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).activate()
        mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).activate()
        mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).activate()
        
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 2/3).activate()

    }
    
    private func configureView() {
        title = viewModel.title
        view.backgroundColor = .white
        
        viewModel.viewModelPublisher
            .sink(receiveValue: configureDetails(movieAttributes:))
            .store(in: &cancellable)
        
        viewModel.viewStatePublisher
            .sink(receiveValue: configure(viewState:))
            .store(in: &cancellable)
        
        viewModel.isFavouritePublisher
            .sink(receiveValue: configureBarButtonItem)
            .store(in: &cancellable)
    }
    
    private func configure(viewState: ViewState) {
        viewState == .loading ? loadingIndicator.startAnimating() : loadingIndicator.stopAnimating()
    }
    
    private func configureDetails(movieAttributes: MovieAttributesViewModel?) {
        guard let movieAttributes else { return }
        imageView.sd_setImage(with: movieAttributes.posterUrl)
        movieAttributes.details.forEach(addDetails(_:))
    }
    
    private func addDetails(_ record: MovieAttributesViewModel.Record) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .firstBaseline
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .right
        titleLabel.text = record.title
        titleLabel.font = .preferredFont(forTextStyle: .subheadline)
        stackView.addArrangedSubview(titleLabel)

        let valueLabel = UILabel()
        valueLabel.text = record.value
        valueLabel.textAlignment = .left
        valueLabel.font = .preferredFont(forTextStyle: .subheadline)
        valueLabel.textColor = .secondaryLabel
        valueLabel.numberOfLines = 0
        stackView.addArrangedSubview(valueLabel)

        detailsStackView.addArrangedSubview(stackView)
        titleLabel.widthAnchor.constraint(equalTo: detailsStackView.widthAnchor, multiplier: 0.3).activate()
    }
    
    private func configureBarButtonItem(isFavourite: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: FavouritingConstant.tooglingIcon(isFavourite: isFavourite),
            style: .plain,
            target: self,
            action: #selector(toogleFavourite)
        )
    }
    
    @objc private func toogleFavourite() {
        viewModel.toogleFavourite()
    }
    
}
