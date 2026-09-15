import Foundation

struct BackgroundMusicResponse: Decodable {
    let success: Bool
    let data: [BackgroundMusic]
}

struct BackgroundMusic: Identifiable, Decodable {
    let id: String
    let title: String
    let author: String
    let category: String
    let audioUrl: String
    let durationSeconds: Double
    let durationFormatted: String
    let fileSizeBytes: Int
    let order: Int

    var durationLabel: String {
        let minutes = Int(durationSeconds) / 60
        let seconds = Int(durationSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
