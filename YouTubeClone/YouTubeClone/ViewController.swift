
import UIKit
import SnapKit
import RxSwift
import Kingfisher


class ViewController: UIViewController {

    let topView = UIView(frame: .zero)
    let videoTableView = UITableView(frame: .zero)
    
    var progressContainerView = UIView(frame: .zero)
    var progressContainerViewConstraint: Constraint!
    var progressContainerImageViewTopConstraint: Constraint!
    var progressContainerImageViewWidthConstraint: Constraint!
    var progressContainerImageViewHeightConstraint: Constraint!
    var progressImageView : UIImageView!
    
    let disposeBag = DisposeBag()
    
    let viewModel = YouTubeVideoViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(topView)
        self.view.addSubview(videoTableView)
        self.view.addSubview(progressContainerView)
        
        videoTableView.register(YouTubeVideoTableViewCell.self, forCellReuseIdentifier: "videoCell")
        videoTableView.rx.setDelegate(self).disposed(by: disposeBag)
        videoTableView.rowHeight = 300

        
        viewModel.videoSubject.bind(to: videoTableView.rx.items(cellIdentifier: "videoCell", cellType: YouTubeVideoTableViewCell.self)) { (index, element, cell) in
            cell.updateUI(viewModel: self.viewModel, item: element)

        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchVideoData().subscribe(onSuccess: { response in
                    print("success")
                }, onFailure: {_ in
                    print("fail")
                }).disposed(by: disposeBag)
        
        setupLayout()
    }

    func setupLayout() {
        topView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        topView.backgroundColor = .red
        
        progressContainerView.backgroundColor = .gray
        
        progressImageView = UIImageView(frame: .zero)
        progressContainerView.addSubview(progressImageView)
        progressImageView.snp.makeConstraints { make in
            progressContainerImageViewWidthConstraint = make.width.equalTo(30).constraint
            progressContainerImageViewHeightConstraint = make.height.equalTo(30).constraint
            progressContainerImageViewTopConstraint = make.top.equalToSuperview().inset(0).constraint
            make.centerX.equalToSuperview()
        }
        progressImageView.isHidden = true
        
        progressContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.topView.snp.bottom)
            progressContainerViewConstraint = make.height.equalTo(0).constraint
        }
        
        progressImageView.image = UIImage(named: "progress")
        
        videoTableView.snp.makeConstraints{ make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset >= 0 {
            progressImageView.isHidden = true
            return
        }
        

        let progressImageOffset = min(-offset/5, 10)
        progressContainerImageViewTopConstraint.update(offset: progressImageOffset)
        progressContainerViewConstraint.update(offset: -offset)
        
        let progressImageSize = min(-offset/5, 30)
        progressContainerImageViewWidthConstraint.update(offset: progressImageSize)
        progressContainerImageViewHeightConstraint.update(offset: progressImageSize)
        
        progressImageView.isHidden = false
        progressImageView.alpha = -offset/100
        
    }

    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 280
//    }
}



class YouTubeVideoTableViewCell: UITableViewCell {
    let thumbnailView: UIImageView = UIImageView(frame: .zero)
    
    let descriptionView: UIView = UIView(frame: .zero)
    let descriptionImageView: UIImageView = UIImageView(frame: .zero)
    let descriptionTitleView: UILabel = UILabel(frame: .zero)
    let descriptionLabelView: UILabel = UILabel(frame: .zero)
    
    let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(thumbnailView)
        self.contentView.addSubview(descriptionView)
        self.descriptionView.addSubview(descriptionImageView)
        self.descriptionView.addSubview(descriptionTitleView)
        self.descriptionView.addSubview(descriptionLabelView)
        
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.height.equalTo(220)
        }

        descriptionView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.top.equalTo(self.thumbnailView.snp.bottom)
            make.bottom.equalTo(self.contentView)
        }

        descriptionImageView.layer.masksToBounds = true
        descriptionImageView.layer.cornerRadius = 40 / 2

        descriptionImageView.snp.makeConstraints { make in
            make.left.equalTo(self.descriptionView).inset(15)
            make.height.equalTo(40)
            make.width.equalTo(40)
            make.top.equalTo(self.descriptionView).inset(10)
        }

        descriptionTitleView.font = UIFont.boldSystemFont(ofSize: 16.0)
        descriptionTitleView.numberOfLines = 2
        descriptionTitleView.lineBreakMode = .byWordWrapping

        descriptionTitleView.snp.makeConstraints { make in
            make.left.equalTo(self.descriptionImageView.snp.right).offset(15)
            make.top.equalTo(self.descriptionView).inset(10)
            make.right.equalTo(self.descriptionView).inset(20)
        }

        descriptionLabelView.font = UIFont.systemFont(ofSize: 13.0, weight: .regular)
        descriptionLabelView.numberOfLines = 1

        descriptionLabelView.snp.makeConstraints { make in
            make.left.equalTo(self.descriptionImageView.snp.right).offset(15)
            make.top.equalTo(self.descriptionTitleView.snp.bottom).offset(5)
            make.width.greaterThanOrEqualTo(50)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    func updateUI(viewModel: YouTubeVideoViewModel, item: YouTubeVideoItem) {

        if let url = item.snippet.thumbnails?.medium?.url {
            thumbnailView.kf.setImage(with: URL(string: url))
        }
        
        descriptionTitleView.text = item.snippet.title
        descriptionLabelView.text = item.snippet.channelTitle + " · " + "조회수 " +  toSimplifyCount(item.statistics.viewCount) + "회"
        
        if let cacheUrl = viewModel.channels[item.snippet.channelId] {
            self.descriptionImageView.kf.setImage(with: URL(string: cacheUrl))
        }
        else {
            viewModel.fetchChannelData(id: item.snippet.channelId).subscribe(onSuccess: { response in
                if let channel =  response?.items.first, let url = channel.snippet.thumbnails?.defaultKey.url{
                    self.descriptionImageView.kf.setImage(with: URL(string: url))
                }

            }, onFailure: {_ in
            }).disposed(by: disposeBag)
        }
    }

    
    func toSimplifyCount(_ string: String) -> String {
        
        let num = Int(string) ?? 0
        //1000
        if string.count == 4 {
            return "\(num / 1000) 천"
        }
        // 10000
        else if string.count >= 5 {
            return "\(num / 10000) 만"
        }
        return "\(num)"
    }
    
}

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

