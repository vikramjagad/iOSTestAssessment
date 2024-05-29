//
//  PostModel.swift
//  iOSTestAssessment
//
//  Created by Vikram Jagad on 29/05/24.
//

import UIKit

struct PostModel: Codable {
    var userId: Int
    var id: Int
    var title: String
    var body: String
}

extension PostModel {
    static func getListData() async -> [PostModel]? {
        let response: WebServiceResponse<[PostModel]> = await WebServices.shared.sendRequest(endPoint: .posts)
        switch response {
        case .failure(let error):
            print("Failure in response: \(error.localizedDescription)")
            return nil
        case .success(let data):
            return data
        }
    }
}
