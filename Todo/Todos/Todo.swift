//
//  Todo.swift
//  PactTodo
//


import Foundation

typealias TodosResult = Result<[Todo], Error>
typealias TodosResultHandler = (TodosResult)->Void

typealias TodoResult = Result<Todo, Error>
typealias TodoResultHandler = (TodoResult)->Void

class Todo {
    // MARK: - Properties
    private(set) var model: TodoModel
    private var original: TodoModel?

    var id: Int {
        get { return model.id }
        set(value) {
            guard value != model.id else { return }
            prepareForChange()
            model.id = value
        }
    }
    
    var title: String {
        get { return model.title }
        set(value) {
            guard value != model.title else { return }
            prepareForChange()
            model.title = value
        }
    }
    
    var details: String {
        get { return model.details }
        set(value) {
            guard value != model.details else { return }
            prepareForChange()
            model.details = value
        }
    }
    
    var priority: Int {
        get { return model.priority }
        set(value) {
            guard value != model.priority else { return }
            prepareForChange()
            model.priority = value
        }
    }
    
    var category: String {
        get { return model.category }
        set(value) {
            guard value != model.category else { return }
            prepareForChange()
            model.category = value
        }
    }
    
    var completed: Bool {
        get { return model.completed }
        set(value) {
            guard value != model.completed else { return }
            prepareForChange()
            model.completed = value
        }
    }
    
    var isNew: Bool { return model.isNew }
    
    // MARK: - Initializers
    
    init(model: TodoModel) {
        self.model = model
    }
    
    init() {
        self.model = TodoModel()
    }
    
    convenience init(withTitle title: String) {
        self.init()
        self.title = title
    }
    
    
    // MARK: - Network Requests
    
    func save(api: TodosApi, completion: @escaping TodoResultHandler) {
        
        if id > 0 {
            update(api: api, completion: completion)
        } else {
            insert(api: api, completion: completion)
        }
        
    }
    
    private func update(api: TodosApi, completion: @escaping TodoResultHandler) {
        
        api.updateTodo(todo: model) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let updated):
                    guard let self = self else { return }
                    self.model = updated
                    self.applyChanges()
                    completion(.success(self))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func insert(api: TodosApi, completion: @escaping TodoResultHandler) {
        
        api.addTodo(todo: model) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let inserted):
                    guard let self = self else { return }
                    self.model = inserted
                    self.applyChanges()
                    completion(.success(self))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    
    func delete(api: TodosApi, completion: @escaping TodoResultHandler) {
        api.deleteTodo(id: model.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    guard let self = self else { return }
                    completion(.success(self))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
    

}

// MARK: - Equatable support for searching in collections
extension Todo: Equatable {
    static func ==(lhs: Todo, rhs: Todo) -> Bool {
        /* BREAKING ATTEMPT #3
         For example due to refactoring we have changed equality rules for todo instances
         and instead of comparing pointers we compare their ids.
         A lot of tests using inserted todos will fail
         That reveals another design problem
         where we didn't make sure that each inserted todo has unique id like -1, -2,..-n
         */
        
        //return lhs.id == rhs.id
        return lhs === rhs
    }
}


// MARK: - Tracking changes
extension Todo {
    
    @discardableResult
    internal func prepareForChange() -> Bool {
        let result = !isDirty
        if result {
            original = model
        }
        return result
    }
    
    @discardableResult
    public func cancelChanges() -> Bool {
        if let original = original {
            self.model = original
            return true
        }
        return false
    }
    
    @discardableResult
    internal func applyChanges() -> Bool {
        let result = isDirty
        if result {
            original = nil
        }
        return result
    }
    
    public var isDirty: Bool {
        return original != nil
    }
}


