//
//  TodosViewModel.swift
//  PactTodo
//

import Foundation

protocol TodosViewModelProtocol {
    func numberOfGroups()->Int
    func numberOfItems(inGroup groupIndex: Int)->Int
    func item(forRow rowIndex: Int, inGroup groupIndex: Int) -> Todo?
    func item(byIndexPath indexPath: IndexPath) -> Todo?
    func item(byId id: Int) -> Todo?
    func download(completion: @escaping TodosResultHandler)
    func save(_ todo: Todo, completion: @escaping TodoResultHandler)
    func delete(_ todo: Todo, completion: @escaping TodoResultHandler)
    func syncCollection(with todo: Todo, modificationType: ModificationType) -> IndexPath?
}

class TodosViewModel: TodosViewModelProtocol {
    
    let api: TodosApi
    
    init(api: TodosApi = TodosApiService()) {
        self.api = api
    }
    
    // MARK: - Data Source
    
    var displayData: [Todo]?
    
    func numberOfGroups()->Int {
        return 1
    }
    
    func numberOfItems(inGroup groupIndex: Int)->Int {
        if let displayData = displayData, groupIndex == 0 {
            return displayData.count
        }
        return 0
    }
    
    func item(forRow rowIndex: Int, inGroup groupIndex: Int = 0) -> Todo? {
        guard groupIndex == 0,
            let displayData = displayData,
            (0 ... displayData.count - 1).contains(rowIndex) else {
                return nil
        }
        
        return displayData[rowIndex]
    }
    
    func item(byIndexPath indexPath: IndexPath) -> Todo? {
        return item(forRow: indexPath.row, inGroup: indexPath.section)
    }
    
    func indexPath(forItem item: Todo) -> IndexPath? {
        if let row = self.displayData?.firstIndex(of: item) {
            return IndexPath(row: row, section: 0)
        }
        return nil
    }
    
    func item(byId id: Int) -> Todo? {
        return self.displayData?.first(where: { $0.id == id })
    }
    
    
    // MARK: - Modification
    func download(completion: @escaping TodosResultHandler) {
        api.getTodos(completion: { [weak self] result in
            if case let .success(models) = result {
                self?.displayData = models.map { Todo.init(model: $0) }
            }
            
            DispatchQueue.main.async {
                switch result {
                case .failure(let error): completion(.failure(error))
                case .success(let models):
                    let todos = models.map { Todo.init(model: $0) }
                    self?.displayData = todos
                    completion(.success(todos))
                }
            }
        })
    }
    
    func save(_ todo: Todo, completion: @escaping TodoResultHandler) {
        todo.save(api: api, completion: completion)
    }
    
    func delete(_ todo: Todo, completion: @escaping TodoResultHandler) {
        todo.delete(api: api, completion: completion )
    }
    
    func syncCollection(with todo: Todo, modificationType: ModificationType) -> IndexPath? {
        var result: IndexPath? = nil
        
        if modificationType == .insert {
            self.displayData?.append(todo)
        }
        
        
        if let row = self.displayData?.firstIndex(of:todo) {
            result = IndexPath(row: row, section: 0)
            
            /* BREAKING ATTEMPT #4
             Imagine during refactoring we forgot to sync up changes after Delete operation
            */
            
            if modificationType == .delete  {
                self.displayData?.remove(at: row)
            }
            //---------------------
        }
        
        
        
        return result
    }
    
}
