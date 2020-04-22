import Foundation

private let sandboxApiUrl = URL(string: "https://sandbox.alloy.co/v1")!
private let productionApiUrl = URL(string: "https://api.alloy.co/v1")!

enum ApiError: Error {
    case couldNotParse
}

internal class API {
    let client: URLSession = {
        return URLSession.shared
    }()

    var apiUrl: URL {
        return production ? productionApiUrl : sandboxApiUrl
    }

    var authString: String? {
        let loginString = String(format: "%@:%@", token, secret)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        return "Basic \(base64LoginString)"
    }

    let token: String
    let secret: String
    let production: Bool

    init(token: String, secret: String, production: Bool = false) {
        self.token = token
        self.secret = secret
        self.production = production
    }

    private func createRequest(path: String, method: String) -> URLRequest {
        var request = URLRequest(url: apiUrl.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(authString, forHTTPHeaderField: "authorization")
        return request
    }

    func evaluate(_ data: AlloyEvaluationData, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = createRequest(path: "/evaluations", method: "POST")

        let jsonData = try! JSONEncoder().encode(data)
        let task = client.uploadTask(with: request, from: jsonData, completionHandler: completion)
        task.resume()
    }

    func create(document: AlloyDocumentData, andUpload data: Data, for entityToken: AlloyEntityToken, completion: @escaping (Result<AlloyDocumentResponse, Error>) -> Void) {
        let request = createRequest(path: "/entities/\(entityToken)/documents", method: "POST")
        let jsonData = try! JSONEncoder().encode(document)
        client.uploadTask(with: request, from: jsonData) { [weak self] data, response, error in
            guard let data = data, let parsed = try? JSONDecoder().decode(AlloyDocumentResponse.self, from: data) else { return }
            self?.upload(document: parsed.token, for: entityToken, data, completion: completion)
        }.resume()
    }

    private func upload(document: AlloyDocumentToken, for entity: AlloyEntityToken, _ data: Data, completion: @escaping (Result<AlloyDocumentResponse, Error>) -> Void) {
        var request = createRequest(path: "/entities/\(entity)/documents/\(document)", method: "PUT")
        request.setValue("image/jpg", forHTTPHeaderField: "content-type")
        client.uploadTask(with: request, from: data) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let data = data, let parsed = try? JSONDecoder().decode(AlloyDocumentResponse.self, from: data) {
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
