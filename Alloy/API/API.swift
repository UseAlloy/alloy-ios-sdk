import Foundation

enum ApiError: Error {
    case couldNotParse
}

internal class API {
    let client: URLSession = {
        return URLSession.shared
    }()

    var apiUrl: URL {
        return URL(string: "https://alloy-test-api.z1.digital")!
    }

    var authString: String? {
        return accessToken.map { token in "Bearer \(token)" }
    }

    let id: String
    let domain: String = Bundle.main.bundleIdentifier ?? ""
    let production: Bool
    var accessToken: String? = nil

    init(id: String, production: Bool = false) {
        self.id = id
        self.production = production
    }

    private func createRequest(path: String, method: String) -> URLRequest {
        var uc = URLComponents(url: apiUrl, resolvingAgainstBaseURL: false)!
        uc.path = path
        uc.queryItems?.append(URLQueryItem(name: "production", value: "\(production)"))

        var request = URLRequest(url: uc.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(authString, forHTTPHeaderField: "authorization")
        return request
    }

    func authInit(completion: @escaping (Optional<Error>) -> Void) {
        let request = createRequest(path: "/auth/init", method: "POST")
        let json = try! JSONEncoder().encode(AlloyInitPayload(id: id, domain: domain))
        client.uploadTask(with: request, from: json) { data, _, error in
            if let error = error {
                completion(error)
                return
            }

            guard let data = data,
                let parsed = try? JSONDecoder().decode(AlloyInitResponse.self, from: data) else {
                    completion(ApiError.couldNotParse)
                    return
            }

            self.accessToken = parsed.accessToken
            completion(nil)
        }.resume()
    }

    func evaluate(_ data: AlloyEvaluationData, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = createRequest(path: "/evaluations", method: "POST")

        let jsonData = try! JSONEncoder().encode(data)
        let task = client.uploadTask(with: request, from: jsonData, completionHandler: completion)
        task.resume()
    }

    func create(document: AlloyDocumentPayload, andUpload image: Data, for entityToken: AlloyEntityToken, completion: @escaping (Result<AlloyDocument, Error>) -> Void) {
        let request = createRequest(path: "/entities/\(entityToken)/documents", method: "POST")
        let jsonData = try! JSONEncoder().encode(document)
        client.uploadTask(with: request, from: jsonData) { [weak self] data, response, error in
            guard let data = data, let parsed = try? JSONDecoder().decode(AlloyDocument.self, from: data) else {
                completion(.failure(ApiError.couldNotParse))
                return
            }
            let upload = AlloyDocumentUpload(token: parsed.token, extension: document.extension, imageData: image)
            self?.upload(document: upload, for: entityToken, completion: completion)
        }.resume()
    }

    private func upload(document: AlloyDocumentUpload, for entity: AlloyEntityToken, completion: @escaping (Result<AlloyDocument, Error>) -> Void) {
        var request = createRequest(path: "/entities/\(entity)/documents/\(document.token)", method: "PUT")
        request.setValue("image/\(document.extension)", forHTTPHeaderField: "content-type")
        client.uploadTask(with: request, from: document.imageData) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data, let parsed = try? JSONDecoder().decode(AlloyDocument.self, from: data) {
                completion(.success(parsed))
                return
            }

            completion(.failure(ApiError.couldNotParse))
        }.resume()
    }

    func evaluate(document: AlloyCardEvaluationData, completion: @escaping (Result<AlloyCardEvaluationResponse, Error>) -> Void) {
        var request = createRequest(path: "/evaluations", method: "POST")
        request.setValue(document.entity.token, forHTTPHeaderField: "Alloy-Entity-Token")
        let jsonData = try! JSONEncoder().encode(document)
        client.uploadTask(with: request, from: jsonData) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data, let parsed = try? JSONDecoder().decode(AlloyCardEvaluationResponse.self, from: data) {
                completion(.success(parsed))
                return
            }

            completion(.failure(ApiError.couldNotParse))
        }.resume()
    }
}
