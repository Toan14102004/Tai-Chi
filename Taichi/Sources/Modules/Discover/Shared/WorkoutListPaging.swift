//
//  WorkoutListPaging.swift
//  Taichi
//
//  Created by Toan Nguyen on 25/8/26.
//

import Foundation

/// Cursor for a paged workout list, shared by the Discover category and Weekly Top screens.
///
/// A value type so a view model can hold it in an `@Published` property and have mutations
/// publish, without either screen re-implementing "which page comes next" or "have we reached the
/// end".
struct WorkoutListPaging {
    private(set) var items: [WorkoutDay] = []
    /// The highest page already merged in; 0 means nothing has loaded yet.
    private(set) var loadedPage = 0
    private(set) var totalPages = 1

    var isEmpty: Bool { items.isEmpty }

    var hasLoaded: Bool { loadedPage > 0 }

    var hasNextPage: Bool { loadedPage < totalPages }

    var nextPage: Int { loadedPage + 1 }

    mutating func reset() {
        self = WorkoutListPaging()
    }

    mutating func apply(_ page: WorkoutPage) {
        // Pages are merged rather than appended blindly: a retry of the page in hand, or a
        // reordering between requests, would otherwise show the same workout twice.
        if page.page <= 1 {
            items = page.items
        } else {
            let known = Set(items.map(\.id))
            items += page.items.filter { !known.contains($0.id) }
        }
        loadedPage = max(loadedPage, page.page)
        totalPages = page.totalPages
    }

    /// True once the list has scrolled close enough to the end to fetch the next page.
    func shouldLoadMore(reaching workout: WorkoutDay, threshold: Int = 3) -> Bool {
        guard hasNextPage,
              let index = items.firstIndex(where: { $0.id == workout.id }) else { return false }
        return index >= items.count - threshold
    }
}
