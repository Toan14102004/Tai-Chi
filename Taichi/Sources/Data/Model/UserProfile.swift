//
//  UserProfile.swift
//  Taichi
//
//  Created by Toan Nguyen on 26/8/26.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var displayName: String = "Guest User"
   
    var avatarImageData: Data?
   
    var streakCount: Int = 0
}
