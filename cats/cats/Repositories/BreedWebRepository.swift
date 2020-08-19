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
    func loadFullBreeds() -> AnyPublisher<([Breed], [BreedImageInfo]), Error>
}

typealias BreedImageInfo = (String, String)

final class RealBreedWebRepository: BreedWebRepository {
    static let shared = RealBreedWebRepository()
    let apiKeyService = ApiKeyService()
    func loadFullBreeds() -> AnyPublisher<([Breed], [BreedImageInfo]), Error> {
        let breedRequest = loadBreeds()
        let imagePublishers = breedRequest.flatMap { breedList in
            return Publishers.MergeMany(breedList.map { self.fetchImage(for: $0.id )}).collect()
        }
        return Publishers.Zip(breedRequest, imagePublishers).eraseToAnyPublisher()
    }
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
    private func fetchImage(for breedId: String) -> AnyPublisher<BreedImageInfo, Error> {
        return Result.Publisher((breedId, "https://wallup.net/wp-content/uploads/2018/03/19/578332-cat-animals-insect-nature-butterfly-748x527.jpg")).eraseToAnyPublisher()
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
