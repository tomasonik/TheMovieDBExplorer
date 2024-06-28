//
//  MoviesListViewController.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import UIKit
import Combine

final class MoviesListViewController: UIViewController {
    
    private enum Constant {
        static let columnsCount: CGFloat = 3
        static let itemSizeAspectRatio: CGFloat = 3/2
    }
    
    private let viewModel: MoviesListViewModel
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    private let flowLayout = UICollectionViewFlowLayout()
    private let itemCellRegistration = MoviesListCollectionViewCell.cellRegistration
    private lazy var dataSource = UICollectionViewDiffableDataSource<Int, Movie.Id>(collectionView: collectionView) { [viewModel, itemCellRegistration]
        collectionView, indexPath, movieId in
        collectionView.dequeueConfiguredReusableCell(
            using: itemCellRegistration,
            for: indexPath,
            item: viewModel.movieItem(with: movieId)
        )
    }
    
    private var cancellables = [AnyCancellable]()
    
    
    init(viewModel: MoviesListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func loadView() {
        super.loadView()
        view.addSubview(collectionView)
        collectionView.fill(view: view)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        configureFlowLayout()
        configureCollectionView()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.onViewWillAppear()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureFlowLayout()
    }
    
    // MARK: -
    
    private func configureCollectionView() {
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = dataSource
        
        viewModel.snapshotPublisher
            .sink(receiveValue: handle(snapshot:))
            .store(in: &cancellables)
    }

    private func configureFlowLayout() {
        let itemWidth = collectionView.bounds.width / Constant.columnsCount
        let itemHeight = itemWidth * Constant.itemSizeAspectRatio
        guard itemWidth > .zero, itemHeight > 0 else { return }
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.invalidateLayout()
    }
    
    private func handle(snapshot: MoviesListViewModel.DataSourceSnapshot) {
        dataSource.apply(snapshot)
    }

}


extension MoviesListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movieId = dataSource.itemIdentifier(for: indexPath) else { return }
        viewModel.tappedItem(movieId: movieId)
    }
    
}
