import Foundation
import Combine

enum APIErrorResponse: Error {
    case invalidStatusCode(_: Int)
    case invalidResponse
    case invalidUrlRequest
    case invalidAuthentication
}
protocol BreedWebRepository {
    func loadBreeds() -> AnyPublisher<[Breed], Error>
}

final class RealBreedWebRepository: BreedWebRepository {
    static let shared = RealBreedWebRepository()
    let apiKeyService = ApiKeyService()
    func loadBreeds() -> AnyPublisher<[Breed], Error> {
        guard let url = buildUrl(.breeds) else {
            print("Invalid URL")
            return Fail(error: APIErrorResponse.invalidUrlRequest).eraseToAnyPublisher()
        }
        guard let apiKey = apiKeyService.retrieveApiKey(for: .breed) else {
            print("Failed to retrieve API Key")
            return Fail(error: APIErrorResponse.invalidAuthentication).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> [Breed] in
                print("Result: \(result.data)")
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw APIErrorResponse.invalidResponse
                }
                guard httpResponse.statusCode == 200 else {
                    throw APIErrorResponse.invalidStatusCode(httpResponse.statusCode)
                }
                let decoder = JSONDecoder()
                let value = try decoder.decode(Breeds.self, from: result.data)
                return value
                
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - Api Endpoints
extension RealBreedWebRepository {
    enum API: String {
        case base = "https://api.thecatapi.com/v1"
        case breeds = "/breeds"
    }
    private func buildUrl(_ request: API) -> URL? {
        switch request {
        case .breeds: return URL(string: API.base.rawValue + API.breeds.rawValue)
        default: return URL(string: API.base.rawValue)
        }
    }
}
