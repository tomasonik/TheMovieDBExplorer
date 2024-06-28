//
//  UICollectionViewCell+Configurable.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import UIKit

protocol Configurable<ViewModel> {
    
    associatedtype ViewModel
    
    func configure(viewModel: ViewModel)
}

extension Configurable where Self: UICollectionViewCell {
    
    static var cellRegistration: UICollectionView.CellRegistration<Self, ViewModel> {
        UICollectionView.CellRegistration<Self, ViewModel> { cell, indexPath, viewModel in
            cell.configure(viewModel: viewModel)
        }
    }
    
}
