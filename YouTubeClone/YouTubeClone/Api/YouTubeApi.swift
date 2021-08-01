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
    private let videoListUrl = "https://www.googleapis.com/youtube/v3/videos"
    private let channelListUrl = "https://www.googleapis.com/youtube/v3/channels"
    
    private let disposeBag = DisposeBag()
    
    func mostPopular() -> Single<YouTubeVideoListResponse?> {
        
        return RxAlamofire.requestData(.get, videoListUrl,
                                       parameters: ["key": self.key, "part": "snippet,statistics, contentDetails", "chart": "mostPopular", "maxResults" : 50])
            .map({ (response, data) -> (YouTubeVideoListResponse?) in
                    // todo error case
           //     print(String(data:data, encoding: .utf8))
                    var result: YouTubeVideoListResponse? = nil
                    do {
                        result = try JSONDecoder().decode(YouTubeVideoListResponse.self, from: data)
                    } catch {
                        return nil
                    }
                    
                    return result
            })
            .asSingle()
    }
    
    
    func channel(id: String) -> Single<YouTubeChannelListResponse?> {
        return RxAlamofire.requestData(.get, channelListUrl, parameters: ["key": self.key, "part": "snippet", "id": id])
                        .map({ (response, data) -> (YouTubeChannelListResponse?) in
                                // todo error case
                        //    print(String(data:data, encoding: .utf8))
                                var result: YouTubeChannelListResponse? = nil
                                do {
                                    result = try JSONDecoder().decode(YouTubeChannelListResponse.self, from: data)
                                } catch {
                                    return nil
                                }
            
                                return result
                        }).asSingle()
    }
    
}


struct YouTubeChannelListResponse: Codable {
    let items: [YouTubeChannelItem]
}

struct YouTubeChannelItem: Codable {
    let kind: String
    let etag: String
    let id: String
    let snippet: YouTubeChannelSnippet
}

struct YouTubeChannelSnippet: Codable {
    let thumbnails: YouTubeThumbnails?
}

struct YouTubeVideoListResponse: Codable {
    let items: [YouTubeVideoItem]
}

struct YouTubeVideoItem: Codable {
    let kind: String
    let etag: String
    let id: String
    let snippet: YouTubeVideoSnippet
    let statistics: YouTubeVideoStatistics
    let contentDetails: YouTubeContentDetails
}

struct YouTubeVideoSnippet: Codable {
    let channelId: String
    let title: String
    let thumbnails: YouTubeThumbnails?
    let channelTitle: String
}

struct YouTubeVideoStatistics: Codable {
    let viewCount: String
}

struct YouTubeContentDetails: Codable {
    let duration: String
}

struct YouTubeThumbnails: Codable {
    let defaultKey: YouTubeThumbnail
    let medium: YouTubeThumbnail?
    let high: YouTubeThumbnail?
    let standard: YouTubeThumbnail?
    
    enum CodingKeys: String, CodingKey {
        case defaultKey = "default"
        case medium
        case high
        case standard
    }
}

struct YouTubeThumbnail: Codable {
    let url: String
}

