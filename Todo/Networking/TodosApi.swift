import Foundation

typealias TodoModelsResult = Result<[TodoModel], Error>
typealias TodoModelsResultHandler = (TodoModelsResult)->Void

typealias TodoModelResult = Result<TodoModel, Error>
typealias TodoModelResultHandler = (TodoModelResult)->Void

protocol TodosApi {
    var baseURL: URL { get }
    
    @discardableResult
    func getTodos(completion: @escaping (TodoModelsResultHandler)) -> URLSessionDataTask
    
    @discardableResult
    func getTodo(
        todoId: Int,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask
    
    @discardableResult
    func addTodo(
        todo: TodoModel,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask
    
    @discardableResult
    func updateTodo(
        todo: TodoModel,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask
    
    @discardableResult
    func deleteTodo(
        id: Int,
        completion: @escaping (TodoModelResultHandler)
    ) -> URLSessionDataTask
}
