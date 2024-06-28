//
//  UIView+Anchors.swift
//  MovieDBExplorer
//
//  Created by Tomasz Horowski on 26/06/2024.
//

import Foundation
import UIKit

extension UIView {
    
    func fill(view: UIView, edges: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: view.topAnchor, constant: edges.top).activate()
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edges.left).activate()
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edges.right).activate()
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -edges.bottom).activate()
    }
    
}

extension NSLayoutConstraint {
    
    func activate() {
        isActive = true
    }
    
}
