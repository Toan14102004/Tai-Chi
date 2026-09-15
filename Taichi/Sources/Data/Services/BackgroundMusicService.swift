import Combine
import Foundation

class BackgroundMusicService {
    static let shared = BackgroundMusicService()
    private let baseURL = "https://tai-chi.limgrow.com"
    private var cancellables = Set<AnyCancellable>()
    private var cachedTracks: [BackgroundMusic] = []

    func fetchBackgroundMusic() -> AnyPublisher<[BackgroundMusic], Error> {
        if !cachedTracks.isEmpty {
            return Just(cachedTracks)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        guard let url = URL(string: "\(baseURL)/background-music") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { $0 as Error }
            .map(\.data)
            .decode(type: BackgroundMusicResponse.self, decoder: JSONDecoder())
            .map { response in
                let tracks = response.data.sorted { $0.order < $1.order }
                self.cachedTracks = tracks
                return tracks
            }
            .eraseToAnyPublisher()
    }
}

