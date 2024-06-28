//
//  ViewLoadingStatus.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 27/06/2024.
//

import Foundation
import Combine

enum ViewState {
    case empty, loading, loaded, error
}

typealias ViewStateSubject = CurrentValueSubject<ViewState, Never>
typealias ViewStatePublisher = AnyPublisher<ViewState, Never>
