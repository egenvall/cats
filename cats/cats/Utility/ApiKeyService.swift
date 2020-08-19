import Foundation
final class ApiKeyService {
    enum ApiService: String {
        case breed = "breedapi"
    }
    func retrieveApiKey(for service: ApiService) -> String? {
        guard let path = Bundle.main.path(forResource: "keys", ofType: "plist"), let dictionary = NSDictionary(contentsOfFile: path) else {
            return nil
        }
        return dictionary[service.rawValue] as? String
    }
}
