//
//  GithubDataService.swift
//  CameraLocation
//
//  Created by Guest User on 23/1/26.
//

import Alamofire
import Combine
import Foundation

class GitHubDataService {
    static let shared = GitHubDataService()
    @Injected var localStorageService: LocalStorageService
    @Injected var keychainStorage: KeychainStorage
 
    private let owner = "LMT2025"
    private let repo = "food_identifier_data"
    private let branch = "dev"
    
    let articleJson = "articles.json"
    let collectionJson = "collection.json"
    
    func getArticleFileName(for languageCode: String) -> String {
        if languageCode == "en" {
            return articleJson
        }
        return "articles_\(languageCode).json"
    }
    
    let githubToken: String = ""
    let session: Session = {
        let configuration = URLSessionConfiguration.af.default

        let interceptor = AuthInterceptor()

        // Config time out
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true

        let networkLogger = GitNetworkLogger()
        return Session(
            configuration: configuration,
            eventMonitors: [networkLogger]
        )
    }()
    
    func getRawURL(for path: String) -> String {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        // Decode first to avoid double encoding if the path is already encoded
        let decodedPath = cleanPath.removingPercentEncoding ?? cleanPath
        let urlString = "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(decodedPath)"
        
        return urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
    }
    
    func fetchFileFromGitHub<T: Codable>(
        filePath: String,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        return fetchFromRawContent(filePath: filePath, responseType: responseType)
//         return fetchViaGitHubAPI(filePath: filePath, responseType: responseType)
    }
    
    func getImageURL(for shortPath: String) -> URL? {
        // Remove leading slash if present to avoid double slashes in URL
        let cleanPath = shortPath.hasPrefix("/") ? String(shortPath.dropFirst()) : shortPath
        let urlString = "https://raw.githubusercontent.com/\(owner)/\(repo)/\(branch)/\(cleanPath)"
        return URL(string: urlString)
    }
    
    /// Fetch raw data from GitHub (JSON, images, etc.)
    func fetchRawData(filePath: String) -> AnyPublisher<Data, NetworkError> {
        Future<Data, NetworkError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknownError))
                return
            }
            
            let url = self.getRawURL(for: filePath)
            
            var headers = HTTPHeaders()
            headers.add(name: "Authorization", value: "token \(self.githubToken)")
            
            self.session.request(url, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        guard !data.isEmpty else {
                            promise(.failure(.noData))
                            return
                        }
                        promise(.success(data))
                    case .failure(let error):
                        self.handleAFError(error: error, response: response.response, promise: promise)
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// Download image from GitHub
    func downloadImage(filePath: String) -> AnyPublisher<Data, NetworkError> {
        fetchRawData(filePath: filePath)
    }

    // MARK: - Private Methods
    
    /// Fetch qua GitHub Contents API
    func fetchViaGitHubAPI<T: Codable>(
        filePath: String,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        Future<T, NetworkError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknownError))
                return
            }
            
            let apiURL = "https://api.github.com/repos/\(self.owner)/\(self.repo)/contents/\(filePath)?ref=\(self.branch)"
            
            var headers = HTTPHeaders()
            headers.add(name: "Content-Type", value: "application/json")
            headers.add(name: "Authorization", value: "Bearer \(githubToken)")
            
            self.session.request(apiURL, headers: headers)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            // Decode GitHub API response
                            let apiResponse = try JSONDecoder().decode(
                                GitHubFileResponse.self,
                                from: data
                            )
                            
                            // Decode base64 content
                            guard let contentData = Data(
                                base64Encoded: apiResponse.content.replacingOccurrences(of: "\n", with: "")
                            ) else {
                                let error = NSError(domain: "GitHubDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode base64 content"])
                                promise(.failure(.decodingError(error)))
                                return
                            }
                            
                            // Decode actual data
                            let decodedData = try JSONDecoder().decode(responseType, from: contentData)
                            promise(.success(decodedData))
                            
                        } catch {
                            promise(.failure(.decodingError(error)))
                        }
                        
                    case .failure(let error):
                        self.handleAFError(error: error, response: response.response, promise: promise)
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// Fetch từ raw.githubusercontent.com
    func fetchFromRawContent<T: Codable>(
        filePath: String,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        Future<T, NetworkError> { [weak self] promise in
            guard let self else {
                promise(.failure(.unknownError))
                return
            }
            
            let url = self.getRawURL(for: filePath)
            
            var headers = HTTPHeaders()
            headers.add(name: "Authorization", value: "token \(githubToken)")
            
            self.session.request(url, headers: headers)
                .validate()
                .responseData { response in
                    self.handleGitHubResponse(
                        response: response,
                        responseType: responseType,
                        promise: promise
                    )
                }
        }
        .eraseToAnyPublisher()
    }
    
    /// Handle GitHub response
    private func handleGitHubResponse<T: Codable>(
        response: AFDataResponse<Data>,
        responseType: T.Type,
        promise: @escaping (Result<T, NetworkError>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            guard !data.isEmpty else {
                promise(.failure(.noData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                promise(.success(decodedResponse))
            } catch {
                print("📥 GitHub Decoding Error: \(error)")
                promise(.failure(.decodingError(error)))
            }
            
        case .failure(let error):
            handleAFError(error: error, response: response.response, promise: promise)
        }
    }
    
    /// Handle Alamofire Error
    private func handleAFError<T>(
        error: AFError,
        response: HTTPURLResponse?,
        promise: @escaping (Result<T, NetworkError>) -> Void
    ) {
        print("📥 GitHub Network Error: \(error)")
        
        if let statusCode = response?.statusCode {
            switch statusCode {
            case 401:
                promise(.failure(.unauthorized))
            case 404:
                promise(.failure(.notFound))
            default:
                let errorMessage = error.localizedDescription
                promise(.failure(.serverError(statusCode, errorMessage)))
            }
        } else {
            promise(.failure(.networkError(error)))
        }
    }
}
