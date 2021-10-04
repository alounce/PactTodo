//
//  TodoModel.swift
//  PactTodo
//


import Foundation

protocol JSONConvertible {
    init?(json: [String: Any])
    func asJSON() -> [String: Any]
}

struct TodoModel: Codable {
    
    var id: Int
    var title: String
    var details: String
    var priority: Int
    var category: String
    var completed: Bool
    var isNew: Bool { return id < 0 }
    
    init() {
        self.id = -1
        self.title = ""
        self.details = ""
        self.priority = 1
        self.category = ""
        self.completed = false
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !isNew { try container.encode(id, forKey: .id) }
        try container.encode(title, forKey: .title)
        try container.encode(details, forKey: .details)
        try container.encode(priority, forKey: .priority)
        try container.encode(category, forKey: .category)
        try container.encode(completed, forKey: .completed)
    }
}

// MARK: - serialization / deserialization for network layer
extension TodoModel: JSONConvertible {
    init?(json: [String: Any]) {
        guard let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let details = json["details"] as? String,
            let priority = json["priority"] as? Int,
            let category = json["category"] as? String,
            let completed = json["completed"] as? Bool else {
                return nil
        }
        self.id = id
        self.title = title
        self.details = details
        self.priority = priority
        self.category = category
        self.completed = completed
    }
    
    func asJSON() -> [String: Any] {
        var json = [String: Any]()
        if !isNew { json["id"] = self.id }
        json["title"] = self.title
        json["details"] = details
        json["priority"] = priority
        json["category"] = category
        json["completed"] = completed
        return json
    }
}

