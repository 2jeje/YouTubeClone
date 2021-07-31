//
//  YouTubeVideoViewModel.swift
//  YouTubeClone
//
//  Created by kakao on 2021/07/31.
//

import RxSwift

class YouTubeVideoViewModel {
    let disposeBag = DisposeBag()
    
    let videoSubject = BehaviorSubject<[YouTubeVideoItem]>(value: [])
    var videos: [YouTubeVideoItem] = []
    var channels: [String: String] = [:]

    func fetchVideoData() -> Single<YouTubeVideoListResponse?>{
        return YouTubeApi.shared.mostPopular().do( onSuccess: { response in
            self.videos = response?.items ?? []
            self.videoSubject.on(.next(self.videos))
        })
    }
    
    func fetchChannelData(id: String) -> Single<YouTubeChannelListResponse?> {
        return YouTubeApi.shared.channel(id: id).do( onSuccess: { response in
            self.channels[id] = response?.items.first?.snippet.thumbnails?.defaultKey.url
        })
    }

}
