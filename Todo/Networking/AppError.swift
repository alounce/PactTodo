import Foundation

enum AppError: String, Error {
    case dataTaskFailure = "data task failure"
    case invalidUrl = "invalid URL"
    case dataNotFound404 = "data not found"
}
