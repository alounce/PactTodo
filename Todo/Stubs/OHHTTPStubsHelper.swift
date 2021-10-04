//
//  OHHTTPStubsHelper.swift
//  PactTodo
//

import Foundation
import OHHTTPStubs

@discardableResult
func stub(withTestEnvironmentInfo info: TestEnvironmentStubInfo) -> OHHTTPStubsDescriptor {
    
    let stubCondition: OHHTTPStubsTestBlock = { request -> Bool in
        let apply = request.url?.path == info.path
            && request.httpMethod == info.method.rawValue
        return apply
    }
    
    let stubResponse: OHHTTPStubsResponseBlock = { _ -> OHHTTPStubsResponse in
        return OHHTTPStubsResponse(jsonObject: info.contentJSON,
                                   statusCode: info.statusCode,
                                   headers: ["Content-Type": "application/json"])
    }
    
    let descriptor = stub(condition: stubCondition, response: stubResponse)
    return descriptor
}
