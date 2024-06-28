//
//  File.swift
//  MovieDBExplorer
//
//  Created by Tomek on 26/06/2024.
//

import Foundation
import UIKit

extension NSDiffableDataSourceSnapshot where SectionIdentifierType == Int {
    
    static var emptySection: NSDiffableDataSourceSnapshot {
        var empty = Self()
        empty.appendSections([0])
        return empty
    }
    
}
