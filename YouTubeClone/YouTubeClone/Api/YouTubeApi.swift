//
//  YouTubeApi.swift
//  YouTubeClone
//
//  Created by kakao on 2021/07/18.
//

import RxAlamofire
import RxSwift
import Foundation

final public class YouTubeApi {
    
    public static let shared = YouTubeApi()
    
    private let key = "AIzaSyBksRMtg6X__Bp12p5ZGtlFjYCpiXyKFcE"
    private var baseUrl = "https://www.googleapis.com/youtube/v3/videos"
    
    private let disposeBag = DisposeBag()
    
    func mostPopular() -> Single<YouTubeVideoResponse?> {
        
        return RxAlamofire.requestData(.get, baseUrl, parameters: ["key": self.key, "part": "snippet", "chart": "mostPopular"])
            .map({ (response, data) -> (YouTubeVideoResponse?) in
                    // todo error case
               // print(String(data:data, encoding: .utf8))
                    var result: YouTubeVideoResponse? = nil
                    do {
                        result = try JSONDecoder().decode(YouTubeVideoResponse.self, from: data)
                    } catch {
                        return nil
                    }
                    
                    return result
            })
            .asSingle()
    }


    
}


struct YouTubeVideoResponse: Codable {
    let items: [YouTubeVideoItem]
}


struct YouTubeVideoItem: Codable {
    let kind: String
    let etag: String
    let id: String
    let snippet: YouTubeVideoSnippet
}


struct YouTubeVideoSnippet: Codable {
    let title: String
    let thumbnails: YouTubeVideoThumbnails
}


struct YouTubeVideoThumbnails: Codable {
    //let default
    let medium: YouTubeVideoThumbnail
    let high: YouTubeVideoThumbnail
    let standard: YouTubeVideoThumbnail
}

struct YouTubeVideoThumbnail: Codable {
    let url: String
}
