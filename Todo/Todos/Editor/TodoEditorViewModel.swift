//
//  TodoEditorViewModel.swift
//  PactTodo
//

import Foundation

protocol TodoEditorViewModelProtocol {
    var todo: Todo { get set }
    var title: String { get }
    init(with todo: Todo, api: TodosApi)
    func update(completion: @escaping TodoResultHandler)
}

class TodoEditorViewModel: TodoEditorViewModelProtocol {
    var todo: Todo
    private let api: TodosApi
    
    required init(with todo: Todo, api: TodosApi = TodosApiService()) {
        self.todo = todo
        self.api = api
    }
    
    var title: String {
        return todo.id < 0 ? "New" : "#\(todo.id)"
    }
    
    func update(completion: @escaping TodoResultHandler) {
        todo.save(api: api, completion: completion)
    }
}
