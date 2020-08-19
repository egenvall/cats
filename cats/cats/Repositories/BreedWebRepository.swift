import Foundation
import Combine

enum APIErrorResponse: Error {
    case invalidStatusCode(_: Int)
    case invalidResponse
    case invalidUrlRequest
}
protocol BreedWebRepository {
    func loadBreeds() -> AnyPublisher<[Breed], Error>
}

final class RealBreedWebRepository: BreedWebRepository {
    static let shared = RealBreedWebRepository()
    
    func loadBreeds() -> AnyPublisher<[Breed], Error> {
        guard let url = buildUrl(.breeds) else {
            return Fail(error: APIErrorResponse.invalidUrlRequest).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> [Breed] in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw APIErrorResponse.invalidResponse
                }
                guard httpResponse.statusCode == 200 else {
                    throw APIErrorResponse.invalidStatusCode(httpResponse.statusCode)
                }
                let decoder = JSONDecoder()
                let value = try decoder.decode([Breed].self, from: result.data)
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
