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
    var entityToken: AlloyEntityToken? = nil
    var externalEntityToken: AlloyEntityToken? = nil

    init(config: Alloy) {
        self.id = config.key
        self.production = config.production
        self.entityToken = config.entityToken
        self.externalEntityToken = config.externalEntityId
    }

    private func createRequest(path: String, method: String, extraQueryItems: [URLQueryItem] = []) -> URLRequest {
        var uc = URLComponents(url: apiUrl, resolvingAgainstBaseURL: false)!
        uc.path = path
        uc.queryItems = uc.queryItems ?? []
        uc.queryItems?.append(URLQueryItem(name: "production", value: "\(production)"))
        uc.queryItems?.append(contentsOf: extraQueryItems)

        var request = URLRequest(url: uc.url!)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(authString, forHTTPHeaderField: "authorization")
        request.setValue(entityToken, forHTTPHeaderField: "Alloy-Entity-Token")
        request.setValue(externalEntityToken, forHTTPHeaderField: "Alloy-External-Entity-ID")
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

    func create(document: AlloyDocumentPayload, andUpload image: Data, completion: @escaping (Result<AlloyDocument, Error>) -> Void) {
        var path = "/documents"
        if let entityToken = entityToken {
            path = "/entities/\(entityToken)\(path)"
        }

        let request = createRequest(path: path, method: "POST")
        let jsonData = try! JSONEncoder().encode(document)
        client.uploadTask(with: request, from: jsonData) { [weak self] data, response, error in
            guard let data = data, let parsed = try? JSONDecoder().decode(AlloyDocument.self, from: data) else {
                completion(.failure(ApiError.couldNotParse))
                return
            }
            let upload = AlloyDocumentUpload(
                token: parsed.token,
                extension: document.extension,
                type: document.type,
                imageData: image
            )
            self?.upload(document: upload, completion: completion)
        }.resume()
    }

    private func upload(document: AlloyDocumentUpload, completion: @escaping (Result<AlloyDocument, Error>) -> Void) {
        var path = "/documents/\(document.token)"
        if let entityToken = entityToken {
            path = "/entities/\(entityToken)\(path)"
        }

        let queryItems = [URLQueryItem(name: "documentType", value: document.type.rawValue)]
        var request = createRequest(path: path, method: "POST", extraQueryItems: queryItems)
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "content-type")

        let body = NSMutableData()
        body.append(convertFileData(
            mimeType: "image/\(document.extension)",
            fileData: document.imageData,
            using: boundary
        ))
        body.appendString("--\(boundary)--")

        client.uploadTask(with: request, from: body as Data) { data, response, error in
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
        let request = createRequest(path: "/evaluations", method: "POST")
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

private func convertFileData(mimeType: String, fileData: Data, using boundary: String) -> Data {
  let data = NSMutableData()

  data.appendString("--\(boundary)\r\n")
  data.appendString("Content-Disposition: form-data; name=\"blob\"; filename=\"blob\"\r\n")
  data.appendString("Content-Type: \(mimeType)\r\n\r\n")
  data.append(fileData)
  data.appendString("\r\n")

  return data as Data
}

private extension NSMutableData {
  func appendString(_ string: String) {
    if let data = string.data(using: .utf8) {
      self.append(data)
    }
  }
}
