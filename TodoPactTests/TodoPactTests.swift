//
//  TodoPactTests.swift
//  TodoPactTests
//


import XCTest
import PactConsumerSwift
@testable import Todo

class TodoPactTests: XCTestCase {
    var provider: PactConsumerSwift.MockService!
    var consumer: TodosApiService!
    
    override func setUp() {
        super.setUp()
        provider =
            PactConsumerSwift.MockService(
                provider: "TodosAPI",
                consumer: "TodosClient"
            )
        consumer =
            TodosApiService(
                baseURL: URL(string: provider.baseUrl)!
            )
    }
    
    override func tearDown() {
        // PLACE CODE HERE
        super.tearDown()
    }
    
    func test_api_get_all_todos() {
        // Arrange
        provider
            .given("we have a todo collection")
            .uponReceiving("a request for all todos")
            .withRequest(
                method: .GET,
                path: "/api/todos",
                headers: ["Accept": "application/json"]
            )
            .willRespondWith(
                status: 200,
                headers: ["Content-Type": "application/json"],
                body: Matcher.eachLike(
                    [
                        "id": Matcher.somethingLike(1),
                        "title": Matcher.somethingLike("Fix switch in bathrom"),
                        "details": Matcher.somethingLike("New switch was already bought"),
                        "priority": Matcher.somethingLike(1),
                        "category": Matcher.somethingLike("home"),
                        "completed": Matcher.somethingLike(false)
                    ],
                    min: 3
                )
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.getTodos { result in
                // Assert
                switch result {
                case .failure(let error): XCTFail(error.localizedDescription)
                case .success(let models): XCTAssertEqual(models.count, 3)
                }
                testCompleted()
            }
        }
    }
    
    func test_api_get_one_todo() {
        
        // Arrange
        provider
            .given("todo item exists")
            .uponReceiving("a request for a todo")
            .withRequest(
                method: .GET,
                path: "/api/todos/3",
                headers: ["Accept": "application/json"]
            )
            .willRespondWith(
                status: 200,
                headers: ["Content-Type": "application/json"],
                body:
                    [
                        "id": Matcher.somethingLike(3),
                        "title": Matcher.somethingLike("To do something important"),
                        "details": Matcher.somethingLike("And of course something useful"),
                        "priority": Matcher.somethingLike(2),
                        "category": Matcher.somethingLike("test"),
                        "completed": Matcher.somethingLike(false)
                    ]
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.getTodo(todoId: 3) { result in
                
                // Assert
                switch result {
                case .failure(let error): XCTFail(error.localizedDescription)
                case .success(let model): XCTAssertNotNil(model)
                }
                testCompleted()
            }
        }
    }
    
    func test_api_get_todo_not_found() {
        
        // Arrange
        provider
            .given("todo item does not exist")
            .uponReceiving("a request for a todo")
            .withRequest(
                method: .GET,
                path: "/api/todos/999",
                headers: ["Accept": "application/json"]
            )
            .willRespondWith(
                status: 404,
                headers: ["Content-Type": "application/json"],
                body: nil
            )
        
        // Act
        provider.run(timeout: 100) { (testCompleted) -> Void in
            self.consumer
                .getTodo(todoId: 999) { result in
                    
                    // Assert
                    switch result {
                    case .failure(let error):
                        XCTAssertNotNil(error)
                        XCTAssertEqual(error as! AppError, AppError.dataNotFound404)
                    case .success(_):
                        XCTFail("response must be null")
                    }
                    testCompleted()
                }
        }
    }
    
    func test_api_create_todo() {
        
        // Arrange
        let modelJSON: [String: Any] = [
            "id": -9,
            "title": "Do something useful",
            "details": "It should be really valuable",
            "priority": 2,
            "category": "Ideas",
            "completed": false
        ]
        
        let requestBodyJSON: [String: Any] = [
            "title": Matcher.somethingLike("Do something useful"),
            "details": Matcher.somethingLike("It should be really valuable"),
            "priority": Matcher.somethingLike(2),
            "category": Matcher.somethingLike("Ideas"),
            "completed": Matcher.somethingLike(false)
        ]
        
        var responseBodyJSON = requestBodyJSON
        responseBodyJSON["id"] = 19
        
        let inputTodo = TodoModel(json: modelJSON)!
        
        provider
            .uponReceiving("create new todo")
            .withRequest(
                method: .POST,
                path: "/api/todos",
                headers: ["Accept": "application/json"],
                body: requestBodyJSON
            )
            .willRespondWith(
                status: 201,
                headers: ["Content-Type": "application/json"],
                body: responseBodyJSON
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.addTodo(todo: inputTodo) { result in
                
                // Assert
                switch result {
                case .failure(let error):
                    XCTFail("must not be an error, but get \(error.localizedDescription)")
                case .success(let outputTodo):
                    XCTAssertNotNil(outputTodo)
                    XCTAssertEqual(outputTodo.id, 19)
                }
                testCompleted()
            }
        }
    }
    
    func test_api_update_todo() {
        
        // Arrange
        
        let modelJSON: [String: Any] = [
            "id": 23,
            "title": "Do something useful",
            "details": "It should be really valuable",
            "priority": 2,
            "category": "Ideas",
            "completed": false
        ]
        let inputTodo = TodoModel(json: modelJSON)!
        
        let requestBodyJSON: [String: Any] = [
            "id": Matcher.somethingLike(23),
            "title": Matcher.somethingLike("Do something useful: Updated!"),
            "details": Matcher.somethingLike("It should be really valuable: Updated!"),
            "priority": Matcher.somethingLike(1),
            "category": Matcher.somethingLike("Ideas"),
            "completed": Matcher.somethingLike(false)
        ]
        
        
        
        provider
            .given("todo item exists")
            .uponReceiving("update todo")
            .withRequest(
                method: .PUT,
                path: "/api/todos/\(inputTodo.id)",
                headers: ["Accept": "application/json"],
                body: requestBodyJSON
            )
            .willRespondWith(
                status: 200,
                headers: ["Content-Type": "application/json"],
                body: requestBodyJSON
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.updateTodo(todo: inputTodo) { result in
                
                // Assert
                switch result {
                case .failure(let error):
                    XCTFail("must not be an error, but get \(error.localizedDescription)")
                case .success(let outputTodo):
                    XCTAssertNotNil(outputTodo)
                    XCTAssertEqual(outputTodo.id, 23)
                }
                testCompleted()
            }
        }
    }
    
    func test_api_update_todo_not_found() {
        
        // Arrange
        let modelJSON: [String: Any] = [
            "id": 999,
            "title": "Do something useful",
            "details": "It should be really valuable",
            "priority": 1,
            "category": "Ideas",
            "completed": false
        ]
        
        let requestBodyJSON: [String: Any] = [
            "id": Matcher.somethingLike(999),
            "title": Matcher.somethingLike("Do something useful"),
            "details": Matcher.somethingLike("It should be really valuable"),
            "priority": Matcher.somethingLike(1),
            "category": Matcher.somethingLike("Ideas"),
            "completed": Matcher.somethingLike(false)
        ]
        
        let inputTodo = TodoModel(json: modelJSON)!
        
        provider
            .given("todo item does not exists")
            .uponReceiving("update todo")
            .withRequest(
                method: .PUT,
                path: "/api/todos/\(inputTodo.id)",
                headers: ["Accept": "application/json"],
                body: requestBodyJSON
            )
            .willRespondWith(
                status: 404,
                headers: ["Content-Type": "application/json"],
                body: nil
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.updateTodo(todo: inputTodo) { result in
                
                // Assert
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error as! AppError, AppError.dataNotFound404)
                case .success(_):
                    XCTFail("response must be null")
                }
                testCompleted()
            }
        }
    }
    
    func test_api_delete_todo() {
        
        // Arrange
        let todoId = 12
        provider
            .given("todo item exists")
            .uponReceiving("delete todo")
            .withRequest(
                method: .DELETE,
                path: "/api/todos/\(todoId)",
                headers: ["Accept": "application/json"],
                body: nil
            )
            .willRespondWith(
                status: 200,
                headers: ["Content-Type": "application/json"],
                body: nil
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.deleteTodo(id: todoId) { result in
                
                // Assert
                switch result {
                case .failure(let error):
                    XCTFail("must not be an error, but get \(error.localizedDescription)")
                case .success(let outputTodo):
                    XCTAssertNotNil(outputTodo)
                    XCTAssertEqual(outputTodo.id, 12)
                }
                testCompleted()
            }
        }
    }
    
    func test_api_delete_todo_not_found() {
        
        // Arrange
        let todoId = 999
        provider
            .given("todo item does not exists")
            .uponReceiving("delete todo")
            .withRequest(
                method: .DELETE,
                path: "/api/todos/\(todoId)",
                headers: ["Accept": "application/json"],
                body: nil
            )
            .willRespondWith(
                status: 404,
                headers: ["Content-Type": "application/json"],
                body: nil
            )
        
        // Act
        provider.run(timeout: 10) { (testCompleted) -> Void in
            self.consumer.deleteTodo(id: todoId) { result in
                
                // Assert
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error as! AppError, AppError.dataNotFound404)
                case .success(_):
                    XCTFail("response must be null")
                }
                testCompleted()
            }
        }
    }
}
