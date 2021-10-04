import Foundation

struct TodosApiService: TodosApi {
    
    init(baseURL: URL = URL(string: "http://localhost:3000")!) {
        self.baseURL = baseURL
    }
    
    private(set) var baseURL: URL
    
    private static var contentTypeHeader: (String, String) {
        //POI:
        //return ("Content-Type", "application/xml")
        return ("Content-Type", "application/json")
    }
    
    @discardableResult
    func getTodos(completion: @escaping (TodoModelsResultHandler)) -> URLSessionDataTask {
        let url = baseURL.appendingPathComponent("/api/todos")
        let request = makeRequest(url: url)
        return retrieveModel(request: request, completion: completion)
    }
    
    @discardableResult
    func getTodo(
        todoId: Int,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask {
        let url = baseURL.appendingPathComponent("/api/todos/\(todoId)")
        let request = makeRequest(url: url)
        return retrieveModel(request: request, completion: completion)
    }
    
    @discardableResult
    func addTodo(
        todo: TodoModel,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask {
        let url = baseURL.appendingPathComponent("/api/todos")
        let body = try? JSONEncoder().encode(todo)
        let request = makeRequest(url: url, method: "post", body: body)
        return retrieveModel(request: request, completion: completion)
    }
    
    @discardableResult
    func updateTodo(
        todo: TodoModel,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask {
        let url = baseURL.appendingPathComponent("/api/todos/\(todo.id)")
        var body: Data? = nil
        do {
            body = try JSONEncoder().encode(todo)
        }
        catch {
            print(error.localizedDescription)
        }
        let request = makeRequest(url: url, method: "put", body: body)
        return retrieveModel(request: request, completion: completion)
        
    }
    
    @discardableResult
    func deleteTodo(
        id: Int,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask {
        let url = baseURL.appendingPathComponent("/api/todos/\(id)")
        let request = makeRequest(url: url, method: "delete")
        return retrieveData(request: request) { result in
            switch result {
            case .failure(let error): completion(.failure(error))
            case .success(_):
                var deleted = TodoModel()
                deleted.id = id
                completion(.success(deleted))
            }
        }
    }
    
    private func makeRequest(
        url: URL,
        method: String = "get",
        headers: [String: String] =
            [
                TodosApiService.contentTypeHeader.0:
                TodosApiService.contentTypeHeader.1,
                "Cache-Control": "no-cache, no-store, must-revalidate",
                "Accept": "application/json"
            ],
        body: Data? = nil
    ) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        headers.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        request.httpBody = body
        return request
    }
    
    private func retrieveModel<T: Decodable>(
        request: URLRequest,
        completion: @escaping (Result<T, Error>) -> (Void)
    ) -> URLSessionDataTask {
        return retrieveData(request: request) { result in
            switch result {
            case .success(let data): decode(data: data, completion: completion)
            case .failure(let error): completion(.failure(error))
            }
        }
    }
    
    private func decode<T: Decodable>(data: Data, completion: (Result<T, Error>) -> (Void)) {
        let decoder = JSONDecoder()
        do {
            let decoded: T = try decoder.decode(T.self, from: data)
            completion(.success(decoded))
        } catch(let error) {
            print("### Decoding error: \(error)")
            completion(.failure(error))
        }
    }
    
    private func retrieveData(
        request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> (Void)
    ) -> URLSessionDataTask {
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if statusCode == 404 {
                completion(.failure(AppError.dataNotFound404))
                return
            }
            
            guard error == nil,
                let data = data,
                200..<300 ~= statusCode else {
                let message = error?.localizedDescription ?? AppError.dataTaskFailure.rawValue
                
                
                    print(message)
                    completion(.failure(error ?? AppError.dataTaskFailure))
                    return
                }
            completion(.success(data))
        }
        task.resume()
        return task
    }
    
}
