//
//  ReminderView.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// Figma: FLow Profile / 05 — Reminder List.
struct ReminderView: View {
    @StateObject var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ProfileNavBar(title: "profile.row.reminder".localizedString, onBack: viewModel.back)

            ScrollView(showsIndicators: false) {
                VStack(spacing: Layout.Spacing.m) {
                    ForEach(viewModel.reminders) { reminder in
                        ReminderCard(
                            reminder: reminder,
                            onToggle: { viewModel.toggle(reminder) },
                            onToggleWeekday: { viewModel.toggleWeekday($0, on: reminder) },
                            onToggleEveryDay: { viewModel.toggleEveryDay(on: reminder) }
                        )
                        .contextMenu {
                            Button("Delete", role: .destructive) { viewModel.delete(reminder) }
                        }
                    }

                    if viewModel.reminders.isEmpty {
                        Text("No reminders yet.")
                            .font(Typography.bodyMedium)
                            .foregroundStyle(Asset.Color.textSecondary.color)
                            .padding(.vertical, Layout.Spacing.xl)
                    }
                }
                .padding(.horizontal, Layout.Spacing.m)
                .padding(.bottom, Layout.Spacing.xl)
            }

            addButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Asset.Color.bgPrimary.color.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: viewModel.load)
        .sheet(isPresented: $viewModel.isAddingReminder) {
            AddReminderTimeSheet(
                onCancel: { viewModel.isAddingReminder = false },
                onDone: { hour, minute in
                    viewModel.add(hour: hour, minute: minute)
                    viewModel.isAddingReminder = false
                }
            )
            .presentationDetents([.height(438)])
        }
        .trackScreen("reminderVC")
    }

    private var addButton: some View {
        Button {
            viewModel.isAddingReminder = true
        } label: {
            HStack(spacing: Layout.Spacing.s + 2) {
                Asset.Icon.Profile.plusIcon.image
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("Add")
                    .font(Typography.bodyLarge)
                    .foregroundStyle(Asset.Color.white.color)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
                .background(Asset.Color.mainColor.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 39.5)
        .padding(.bottom, Layout.Spacing.m)
    }
}

#Preview {
    ReminderView()
        .preview()
}
