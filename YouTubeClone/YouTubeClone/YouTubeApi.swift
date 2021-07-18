//
//  YouTubeApi.swift
//  YouTubeClone
//
//  Created by kakao on 2021/07/18.
//

import RxAlamofire
import RxSwift

final public class YouTubeApi {
    
    public static let shared = YouTubeApi()
    
    
    private let disposeBag = DisposeBag()
    
    func search(text: String) -> Single<SearchInfo> {
        
        RxAlamofire.requestData(.get, <#T##url: URLConvertible##URLConvertible#>, parameters: <#T##Parameters?#>, encoding: <#T##ParameterEncoding#>, headers: <#T##HTTPHeaders?#>, interceptor: <#T##RequestInterceptor?#>)
    }


    
}


struct SearchInfo: Codable {
    
}
