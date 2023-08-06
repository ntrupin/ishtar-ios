//
//  ExtCollection.swift
//  project1810
//
//  Created by Noah Trupin on 10/6/21.
//

import SwiftUI

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    subscript (safe range: Range<Index>) -> Self.SubSequence? {
        return indices.contains(range.lowerBound) && indices.contains(range.upperBound) ? self[range] : nil
    }
}
