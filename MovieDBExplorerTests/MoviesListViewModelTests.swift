//
//  MoviesListViewModelTests.swift
//  MovieDBExplorerTests
//
//  Created by Tomek on 27/06/2024.
//

import XCTest
import Combine
@testable import MovieDBExplorer


final class MoviesListViewModelTests: XCTestCase {

    private var viewModel: MoviesListViewModel!
    private var mockMoviesFavoritingService: MockMoviesFavoritingService!
    private var mockMovesListCoordinator: MockMovesListCoordinator!
    private var stupMoviesResponseProvider: PassthroughSubject<MoviesResponse, Error>!
    private var spySnapshot: AnyPublisher<[MoviesListViewModel.DataSourceSnapshot], Never>!

    let stubMovie1 = Movie.stub(id: 1, title: "stubbedTitle1"),
        stubMovie2 = Movie.stub(id: 2, title: "stubbedTitle2"),
        stubMovie3 = Movie.stub(id: 3, title: "stubbedTitle3")
    
    private lazy var stubbedMoviesResponse = MoviesResponse(
        results: [stubMovie1, stubMovie2, stubMovie3]
    )
    
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMoviesFavoritingService = MockMoviesFavoritingService()
        mockMovesListCoordinator = MockMovesListCoordinator()
        stupMoviesResponseProvider = PassthroughSubject<MoviesResponse, Error>()
        
        viewModel = .init(
            moviesProvider: stupMoviesResponseProvider.eraseToAnyPublisher(),
            coordinator: mockMovesListCoordinator,
            moviesFavouriting: mockMoviesFavoritingService
        )
        
        spySnapshot = viewModel.snapshotPublisher.collect(1).first().eraseToAnyPublisher()
    }
    
    
    override func tearDownWithError() throws {
        viewModel = nil
        stupMoviesResponseProvider = nil
        mockMoviesFavoritingService = nil
        mockMovesListCoordinator = nil
        spySnapshot = nil
        try super.tearDownWithError()
    }

    
    // MARK: -
    
    func testOnViewVillAppear_RequestSucceeds_UpdatesSnapshot() throws {
        viewModel.onViewWillAppear()
        
        stupMoviesResponseProvider.send(stubbedMoviesResponse)
        
        XCTAssertEqual(
            try awayResult(from: spySnapshot).first?.itemIdentifiers,
            stubbedMoviesResponse.results.map(\.id)
        )
    }
    
    
    func testOnViewVillAppear_RequestSucceeds_ReturnsViewModel() throws {
        try givenViewModelsLoaded()
        
        XCTAssertEqual(
            viewModel.movieItem(with: stubMovie2.id)?.title,
            "stubbedTitle2"
        )
    }
    
    
    // MARK: -
    
    func testOnViewVillAppear_HasFavoriteItem_ReturnsFavouriteViewModel() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie2.id]
        
        try givenViewModelsLoaded()
        
        XCTAssertEqual(
            viewModel.movieItem(with: stubMovie2.id)?.isFavourite,
            true
        )
    }
    
    
    func testOnViewVillAppear_NasNoFavoriteItem_ReturnsNoFavouriteViewModel() throws {
        try givenViewModelsLoaded()
        
        XCTAssertEqual(
            viewModel.movieItem(with: stubMovie2.id)?.isFavourite,
            false
        )
    }
    
    
    // MARK: -
    
    func testToggle_IsFavourite_TogglesItem() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie1.id]
        try givenViewModelsLoaded()
        
        viewModel.movieItem(with: stubMovie1.id)?.toogleFavourite()
        
        XCTAssertEqual(mockMoviesFavoritingService.spyRemoveFromFavourite, [stubMovie1.id])
    }


    func testToggle_IsNotFavourite_TogglesItem() throws {
        try givenViewModelsLoaded()
        
        viewModel.movieItem(with: stubMovie1.id)?.toogleFavourite()
        
        XCTAssertEqual(mockMoviesFavoritingService.spyAddToFavourite, [stubMovie1.id])
    }
    
    
    // MARK: -
    
    func testRefreshFavoriting_HasRefreshedViewModel_ReconfigureSnapshot() throws {
        try givenViewModelsLoaded()
        
        mockMoviesFavoritingService.stubChangesPublisher.send(stubMovie3.id)
        
        XCTAssertEqual(try awayResult(from: spySnapshot).last?.reconfiguredItemIdentifiers, [stubMovie3.id])
    }
    
    
    func testRefreshFavoriting_HasRefreshedViewModel_BecomesFavourite_ViewModelIsUpdated() throws {
        try givenViewModelsLoaded()
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, false)

        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie3.id]
        mockMoviesFavoritingService.stubChangesPublisher.send(stubMovie3.id)
        try awayResult(from: spySnapshot)
        
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, true)
    }
    
    
    func testRefreshFavoriting_HasRefreshedViewModel_BecomesNotFavourite_ViewModelIsUpdated() throws {
        mockMoviesFavoritingService.stubFavouriteIds = [stubMovie3.id]
        try givenViewModelsLoaded()
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, true)

        mockMoviesFavoritingService.stubFavouriteIds = []
        mockMoviesFavoritingService.stubChangesPublisher.send(stubMovie3.id)
        try awayResult(from: spySnapshot)
        
        XCTAssertEqual(viewModel.movieItem(with: stubMovie3.id)?.isFavourite, false)
    }
    
    
    // MARK: -
    
    private func givenViewModelsLoaded() throws {
        viewModel.onViewWillAppear()
        stupMoviesResponseProvider.send(stubbedMoviesResponse)
        try awayResult(from: spySnapshot)
    }
}
