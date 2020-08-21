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
    func loadFullBreeds() -> AnyPublisher<[Breed], Error>
}


final class RealBreedWebRepository: BreedWebRepository {
    static let shared = RealBreedWebRepository()
    let apiKeyService = ApiKeyService()
    func loadFullBreeds() -> AnyPublisher<([Breed]), Error> {
        let breedRequest = loadBreeds()
//        let imagePublishers = breedRequest.flatMap { breedList in
//            return Publishers.MergeMany(breedList.map { self.fetchImage(for: $0.id )}).collect()
//        }
//        return Publishers.Zip(breedRequest, imagePublishers).eraseToAnyPublisher()
        return breedRequest.eraseToAnyPublisher()
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
        guard let url = buildUrl(.thumbnail) else {
            print("Invalid URL")
            return Fail(error: APIErrorResponse.invalidUrlRequest).eraseToAnyPublisher()
        }
        guard let apiKey = apiKeyService.retrieveApiKey(for: .breed) else {
            print("Failed to retrieve API Key")
            return Fail(error: APIErrorResponse.invalidAuthentication).eraseToAnyPublisher()
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [breedQuery(breedId), limitQuery(1)]
        guard let queriedUrl = components?.url else {
            return Fail(error: APIErrorResponse.invalidUrlRequest).eraseToAnyPublisher()
        }
        var request = URLRequest(url: queriedUrl)
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result -> BreedImageInfo in
                print("Result: \(result.data)")
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw APIErrorResponse.invalidResponse
                }
                guard httpResponse.statusCode == 200 else {
                    throw APIErrorResponse.invalidStatusCode(httpResponse.statusCode)
                }
                let decoder = JSONDecoder()
                let value = try decoder.decode(BreedImageInfo.self, from: result.data)
                return value
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
        
        //return Result.Publisher((breedId, "https://wallup.net/wp-content/uploads/2018/03/19/578332-cat-animals-insect-nature-butterfly-748x527.jpg")).eraseToAnyPublisher()
    }
}

// MARK: - Api Endpoints
extension RealBreedWebRepository {
    enum API: String {
        case base = "https://api.thecatapi.com/v1"
        case breeds = "/breeds"
        case thumbnail = "/images/search"
    }
    
    
    private func buildUrl(_ request: API) -> URL? {
        switch request {
        case .breeds: return URL(string: buildUrlPath(.breeds))
        case .thumbnail: return URL(string: buildUrlPath(.thumbnail))
        default: return URL(string: buildUrlPath(.base))
        }
    }
    private func buildUrlPath(_ request: API) -> String {
        switch request {
        case .breeds: return API.base.rawValue + API.breeds.rawValue
        case .thumbnail: return API.base.rawValue + API.thumbnail.rawValue
        default: return API.base.rawValue
        }
    }
    private func limitQuery(_ limit: Int) -> URLQueryItem {
        return URLQueryItem(name: "limit", value: "\(limit)")
    }
    private func breedQuery(_ breedId: String) -> URLQueryItem {
        return URLQueryItem(name: "breed_id", value: breedId)
    }
}
