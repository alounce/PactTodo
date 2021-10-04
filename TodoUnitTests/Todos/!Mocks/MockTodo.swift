//
//  MockTodo.swift
//  PactTodoUnitTests
//

import UIKit

@testable import Todo

/* POI: Subclass to create Mock:
 this is a technique which is compormise between being pure and simple
 For cases when we still don't want to completelly re-implement tested object
 but we don't want to invoke network layer it possible to subclass tested object to have "kinda" Mock
 
 Used in Editor/TodoEditorViewControllerTest.swift
 */

class MockTodo: Todo {
    
    static var lastError: Error? = nil
    static var loadWasCalled: Bool = false
    static var loadShouldFail: Bool = false
    
    var updateWasCalled: Bool = false
    var updateShouldFail: Bool = false
    
    var deleteWasCalled: Bool = false
    var deleteShouldFail: Bool = false
    
    
    
    
    static func setupTestError() -> Error {
        return NSError(domain: "com.vivint.test",
                       code: 777,
                       userInfo: [kCFErrorLocalizedDescriptionKey as String: "Test Error"])
    }
    
    override func save(
        api: TodosApi,
        completion: @escaping TodoResultHandler
    ) {
        updateWasCalled = true
        MockTodo.lastError = updateShouldFail ? MockTodo.setupTestError(): nil
        if let error = MockTodo.lastError {
            completion(.failure(error))
        } else {
            completion(.success(self))
        }
    }
    
    override func delete(
        api: TodosApi,
        completion: @escaping TodoResultHandler
    ) {
        deleteWasCalled = true
        MockTodo.lastError = updateShouldFail ? MockTodo.setupTestError() : nil
        if let error = MockTodo.lastError {
            completion(.failure(error))
        } else {
            completion(.success(self))
        }
    }
}
