//
//  NetworkLogger.swift
//  Taichi
//
//  Created by Toan Nguyen on 12/12/24.
//

import Alamofire
import Foundation

final class GitNetworkLogger: EventMonitor {
    let queue = DispatchQueue(label: "com.limgrow.taichi.network.logger")

    func requestDidFinish(_: Request) {
//        print(request.description)
    }

    func request(
        _: DataRequest,
        didParseResponse _: DataResponse<some Any, AFError>
    ) {
//        guard let data = response.data else {
//            return
//        }
//        if let json = try? JSONSerialization
//            .jsonObject(with: data, options: .mutableContainers) {
//            print(json)
//        }
    }
}
