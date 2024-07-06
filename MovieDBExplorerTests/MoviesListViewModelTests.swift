//
//  MoviesListViewModelTests.swift
//  MovieDBExplorerTests
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import XCTest
import Combine
import CombineSchedulers
@testable import MovieDBExplorer


final class MoviesListViewModelTests: XCTestCase {

    private var viewModel: MoviesListViewModel!
    private var mockMoviesFavoritingService: MockMoviesFavoritingService!
    private var mockMovesListCoordinator: MockMovesListCoordinator!
    private var stupMoviesResponseProvider: PassthroughSubject<MoviesResponse, Error>!
    
    private var spySnapshots = [MoviesListViewModel.DataSourceSnapshot]()
    
    private let stubMovie1 = Movie.stub(id: 1, title: "stubbedTitle1"),
                stubMovie2 = Movie.stub(id: 2, title: "stubbedTitle2"),
                stubMovie3 = Movie.stub(id: 3, title: "stubbedTitle3")
    
    private let immediateScheduler: AnySchedulerOf<DispatchQueue> = .immediate
    
    private lazy var stubbedMoviesResponse = MoviesResponse(
        results: [stubMovie1, stubMovie2, stubMovie3]
    )
    
    private var cancellables = [AnyCancellable]()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMoviesFavoritingService = MockMoviesFavoritingService()
        mockMovesListCoordinator = MockMovesListCoordinator()
        stupMoviesResponseProvider = PassthroughSubject<MoviesResponse, Error>()
        
        viewModel = .init(
            moviesProvider: stupMoviesResponseProvider.eraseToAnyPublisher(),
            coordinator: mockMovesListCoordinator,
            moviesFavouriting: mockMoviesFavoritingService,
            mainScheduler: immediateScheduler
        )
        
        viewModel.$snapshot
            .append(to: \.spySnapshots, on: self)
            .store(in: &cancellables)
    }
    
    
    override func tearDownWithError() throws {
        viewModel = nil
        stupMoviesResponseProvider = nil
        mockMoviesFavoritingService = nil
        mockMovesListCoordinator = nil
        spySnapshots = []
        cancellables = []
        try super.tearDownWithError()
    }

    
    // MARK: -
    
    func testOnViewVillAppear_RequestSucceeds_UpdatesSnapshot() throws {
        viewModel.onViewWillAppear()
        
        stupMoviesResponseProvider.send(stubbedMoviesResponse)
        
        XCTAssertEqual(
            spySnapshots.last?.itemIdentifiers,
            stubbedMoviesResponse.results.map(\.id)
        )
    }
    
    
    func testOnViewVillAppear_RequestSucceeds_ReturnsViewModel() throws {
        givenViewModelsLoaded()
        
        XCTAssertEqual(
            viewModel.movieItem(with: stubMovie2.id)?.title,
            "stubbedTitle2"
        )
    }
    
    
    // MARK: -
    
    func testOnViewVillAppear_HasFavoriteItem_ReturnsFavouriteViewModel() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie2.id]
        
        givenViewModelsLoaded()
        
        XCTAssertEqual(
            viewModel.movieItem(with: stubMovie2.id)?.isFavourite,
            true
        )
    }
    
    
    func testOnViewVillAppear_NasNoFavoriteItem_ReturnsNoFavouriteViewModel() throws {
        givenViewModelsLoaded()
        
        XCTAssertEqual(
            viewModel.movieItem(with: stubMovie2.id)?.isFavourite,
            false
        )
    }
    
    
    // MARK: -
    
    func testToggle_IsFavourite_TogglesItem() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie1.id]
        givenViewModelsLoaded()
        
        viewModel.movieItem(with: stubMovie1.id)?.toogleFavourite()
        
        XCTAssertEqual(mockMoviesFavoritingService.spyRemoveFromFavourite, [stubMovie1.id])
    }


    func testToggle_IsNotFavourite_TogglesItem() throws {
        givenViewModelsLoaded()
        
        viewModel.movieItem(with: stubMovie1.id)?.toogleFavourite()
        
        XCTAssertEqual(mockMoviesFavoritingService.spyAddToFavourite, [stubMovie1.id])
    }
    
    
    // MARK: -
    
    func testRefreshFavoriting_HasRefreshedViewModel_ReconfigureSnapshot() throws {
        givenViewModelsLoaded()
        
        mockMoviesFavoritingService.stubChangesPublisher.send(stubMovie3.id)
        
        XCTAssertEqual(spySnapshots.last?.reconfiguredItemIdentifiers, [stubMovie3.id])
    }
    
    
    func testRefreshFavoriting_BecomesFavourite_MovieItemIsUpdated() throws {
        givenViewModelsLoaded()
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, false)

        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie3.id]
        mockMoviesFavoritingService.stubChangesPublisher.send(stubMovie3.id)
        
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, true)
    }
    
    
    func testRefreshFavoriting_BecomesNotFavourite_MovieItemIsUpdated() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie3.id]
        givenViewModelsLoaded()
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, true)

        mockMoviesFavoritingService.stubFavouriteIds = []
        mockMoviesFavoritingService.stubChangesPublisher.send(stubMovie3.id)

        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, false)
    }
    
    
    // MARK: -
    
    func testTappedItem_NavigatesWithMovieId() throws {
        givenViewModelsLoaded()
        viewModel.tappedItem(movieId: stubMovie1.id)
        XCTAssertEqual(mockMovesListCoordinator.spyOnEnteringMovieId, [stubMovie1.id])
    }
    
    
    func testTappedItem_NavigatesWithMovieTitle() throws {
        givenViewModelsLoaded()
        viewModel.tappedItem(movieId: stubMovie1.id)
        XCTAssertEqual(mockMovesListCoordinator.spyOnEnteringMovieTitle, [stubMovie1.title])
    }
    
    // MARK: -
    
    private func givenViewModelsLoaded() {
        viewModel.onViewWillAppear()
        stupMoviesResponseProvider.send(stubbedMoviesResponse)
        XCTAssertEqual(spySnapshots.last?.itemIdentifiers, stubbedMoviesResponse.results.map { $0.id })
    }
}
