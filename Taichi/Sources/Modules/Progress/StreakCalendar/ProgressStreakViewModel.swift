//
//  ProgressStreakViewModel.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Combine
import Foundation

extension ProgressStreakView {
    class ViewModel: BaseViewModel {
        @Navigation var navigator
        @Injected var progressService: ProgressService

        @Published var coordinator = Coordinator()
        @Published var month = Date()
        @Published var activeDates: Set<String> = []
        @Published var streakDays = 0
        @Published var isLoading = false
        @Published var errorMessage: String?

        private var cancellables = Set<AnyCancellable>()

        /// The full grid of weeks the calendar draws for `month`, including the leading and
        /// trailing days of neighbouring months needed to fill whole weeks.
        var gridDays: [Date] {
            var calendar = Calendar.current
            calendar.firstWeekday = 1 // Sunday -- `2168:5690`'s header row reads "Su Mo Tue We Th Fr Sa"

            guard let monthInterval = calendar.dateInterval(of: .month, for: month),
                  let firstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
                  let lastWeek = calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.start)
            else { return [] }

            var days: [Date] = []
            var cursor = firstWeek.start
            while cursor < lastWeek.end {
                days.append(cursor)
                guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
                cursor = next
            }
            return days
        }

        func loadIfNeeded() {
            guard activeDates.isEmpty, streakDays == 0, !isLoading else { return }
            load()
        }

        func load() {
            guard let first = gridDays.first, let last = gridDays.last else { return }
            isLoading = true
            errorMessage = nil

            progressService.registerDeviceIfNeeded()
                .flatMap { [progressService] _ in progressService.dailyTotals(from: first, to: last) }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self else { return }
                    isLoading = false
                    if case let .failure(error) = completion {
                        errorMessage = error.errorDescription
                    }
                } receiveValue: { [weak self] days in
                    guard let self else { return }
                    activeDates = Set(days.filter { $0.calories > 0 || $0.durationMinutes > 0 }
                        .map { ProgressService.dayFormatter.string(from: $0.date) })
                    streakDays = progressService.streakDays(endingOn: Date(), in: days)
                }
                .store(in: &cancellables)
        }

        func isActive(_ day: Date) -> Bool {
            activeDates.contains(ProgressService.dayFormatter.string(from: day))
        }

        func isInDisplayedMonth(_ day: Date) -> Bool {
            Calendar.current.isDate(day, equalTo: month, toGranularity: .month)
        }

        // MARK: - Month navigation

        func previousMonth() {
            guard let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: month) else { return }
            month = newMonth
            load()
        }

        func nextMonth() {
            guard let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: month) else { return }
            month = newMonth
            load()
        }

        func back() {
            navigator.goBack()
        }
    }
}
