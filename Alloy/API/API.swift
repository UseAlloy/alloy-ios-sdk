import Foundation

private let sandboxApiUrl = URL(string: "https://sandbox.alloy.co/v1")!
private let productionApiUrl = URL(string: "https://api.alloy.co/v1")!

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

//    func authorization() {
//        let requestUrl = apiUrl.appendingPathComponent("/oauth/bearer")
//        var request = URLRequest(url: requestUrl)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "content-type")
//        request.setValue(authString, forHTTPHeaderField: "Authorization")
//
//        let task = client.dataTask(with: request) { (data, response, error) in
//            print(String(data: data!, encoding: .utf8))
//            print(response)
//            print(error)
//        }
//        task.resume()
//    }

    func evaluate(_ data: AlloyEvaluationData, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let request = createRequest(path: "/evaluations", method: "POST")

        let jsonData = try! JSONEncoder().encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)
        print(jsonString!)
        print("---")

        let task = client.uploadTask(with: request, from: jsonData, completionHandler: completion)
        task.resume()

//        let task = client.uploadTask(with: request, from: jsonData) { (data, response, error) in
//            let parsed = try! JSONDecoder().decode(AlloyEvaluationResponse.self, from: data!)
//            print(parsed)
//
//            print(String(data: data!, encoding: .utf8)!)
//            print(response!)
//            print(error)
//        }
    }

    func describe(document: AlloyDocumentData, for entityToken: AlloyEntityToken? = nil) {
        let request = createRequest(path: "/entities/\(entityToken)/documents", method: "POST")

        guard let jsonData = try? JSONEncoder().encode(document) else {
            return
        }

        let task = client.uploadTask(with: request, from: jsonData) { data, response, error in
            guard let data = data, let parsed = try? JSONDecoder().decode(AlloyDocumentResponse.self, from: data) else {
                return
            }

            print(parsed)
        }

        task.resume()
    }
}
