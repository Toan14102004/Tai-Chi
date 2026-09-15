//
//  ProgressActivityIcon.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import SwiftUI

/// Maps `/activity-categories`' `iconKey` to an SF Symbol. The API serves no icon image, only
/// this key, and Figma's own icon set for the 46 activity types has not been exported -- see
/// docs/README.md for the same trade-off elsewhere in Discover. Covers the categories Figma shows
/// plus the rest of the API's list; anything unrecognised falls back to a generic glyph rather
/// than showing nothing.
enum ProgressActivityIcon {
    static func systemName(for iconKey: String?) -> String {
        switch iconKey {
        case "walking", "race_walking": "figure.walk"
        case "running": "figure.run"
        case "dance": "figure.dance"
        case "yoga", "mind_body", "tai_chi": "figure.yoga"
        case "cycling": "figure.outdoor.cycle"
        case "swimming": "figure.pool.swim"
        case "jump_rope": "figure.jumprope"
        case "elliptical": "figure.elliptical"
        case "hiking": "figure.hiking"
        case "climbing": "figure.climbing"
        case "boxing", "wrestling": "figure.boxing"
        case "rowing": "figure.rower"
        case "skating", "water_skiing", "skiing": "figure.skiing.downhill"
        case "skateboarding": "figure.skateboarding"
        case "surfing": "figure.surfing"
        case "stair_climbing": "figure.stairs"
        case "basketball": "figure.basketball"
        case "soccer": "figure.soccer"
        case "tennis", "table_tennis", "squash", "badminton": "figure.tennis"
        case "volleyball": "figure.volleyball"
        case "baseball", "softball": "figure.baseball"
        case "golf": "figure.golf"
        case "bowling": "figure.bowling"
        case "archery": "figure.archery"
        case "fencing": "figure.fencing"
        case "handball": "figure.handball"
        case "field_hockey", "ice_hockey", "floorball": "figure.hockey"
        case "fishing": "figure.fishing"
        case "cricket", "rugby", "dodgeball", "zorbing", "billiards": "figure.mixed.cardio"
        default: "figure.mixed.cardio"
        }
    }
}

extension ProgressCategory {
    var systemImageName: String { ProgressActivityIcon.systemName(for: iconKey) }
}

extension ProgressActivity {
    var systemImageName: String { ProgressActivityIcon.systemName(for: iconKey) }
}
