
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
    var videoTableViewTopConstraint: Constraint!
    
    var topViewTopConstraint: Constraint!
    var totalTopViewConstraint: CGFloat = 0 {
        didSet {
            self.topViewTopConstraint.update(inset: totalTopViewConstraint)
        }
    }
    
    var progressView : UIActivityIndicatorView!
    
    
    let disposeBag = DisposeBag()
    
    let viewModel = YouTubeVideoViewModel()
    
    
    var previousTopViewOffset: CGFloat = 0.0
    
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
            topViewTopConstraint = make.top.equalTo(self.view.safeAreaLayoutGuide).constraint
            make.height.equalTo(40)
        }
        topView.layer.masksToBounds = true
        
        let logoImageView = UIImageView(frame: .zero)
        logoImageView.image = UIImage(named: "logo")
        topView.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
            make.width.equalTo(85)
            make.height.equalTo(85 * 178 / 794) // logo size
        }
        
        progressView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        progressContainerView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            progressContainerImageViewWidthConstraint = make.width.equalTo(30).constraint
            progressContainerImageViewHeightConstraint = make.height.equalTo(30).constraint
            progressContainerImageViewTopConstraint = make.top.equalToSuperview().inset(0).constraint
            make.centerX.equalToSuperview()
        }
        progressView.isHidden = true
        
        progressContainerView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.topView.snp.bottom)
            progressContainerViewConstraint = make.height.equalTo(0).constraint
        }
        
        videoTableView.snp.makeConstraints{ make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            videoTableViewTopConstraint = make.top.equalTo(topView.snp.bottom).constraint
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        let statusBarView = UIView(frame: .zero)
        self.view.addSubview(statusBarView)
            
        statusBarView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.top)
        }
        statusBarView.backgroundColor = .white
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // go up
        if velocity.y < 0 {
            if isTop(scrollView) && scrollView.contentOffset.y < -50 {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                videoTableViewTopConstraint.update(inset: -50)
                
                viewModel.fetchVideoData().subscribe(onSuccess: { [weak self] response in
                    self?.videoTableViewTopConstraint.update(inset: 0)
                }, onFailure: {[weak self] _ in
                    self?.videoTableViewTopConstraint.update(inset: 0)
                }).disposed(by: disposeBag)
            }
            
            totalTopViewConstraint = 0
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
        else {
            totalTopViewConstraint = -30
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let velocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
         
        if isTop(scrollView) {
            totalTopViewConstraint = 0

            let progressImageOffset = min(-offset/5, 10)
            progressContainerImageViewTopConstraint.update(offset: progressImageOffset)
            progressContainerViewConstraint.update(offset: -offset)
            
            let progressImageSize = min(-offset/5, 30)
            progressContainerImageViewWidthConstraint.update(offset: progressImageSize)
            progressContainerImageViewHeightConstraint.update(offset: progressImageSize)
            
            progressView.isHidden = false
            progressView.alpha = -offset/50
            progressView.startAnimating()
            previousTopViewOffset = offset
            return
        }
        
        // go down
        if velocity < 0 {
            totalTopViewConstraint = max(totalTopViewConstraint + (previousTopViewOffset - offset), -30)
        }
        
        previousTopViewOffset = offset

    }
    
    func isBotton(_ scrollView: UIScrollView) -> Bool {
        
        let offset = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        let distanceFromBottom = scrollView.contentSize.height - offset
        if distanceFromBottom < height {
            return true
        }
        return false
    }

    
    func isTop(_ scrollView: UIScrollView) -> Bool {
        let offset = scrollView.contentOffset.y
        if offset <= 0 {
            return true
        }
        return false
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 280
//    }
}



class YouTubeVideoTableViewCell: UITableViewCell {
    let thumbnailView: UIImageView = UIImageView(frame: .zero)
    let durationLabel: PaddingLabel = PaddingLabel(frame: .zero)
    
    let descriptionView: UIView = UIView(frame: .zero)
    let descriptionImageView: UIImageView = UIImageView(frame: .zero)
    let descriptionTitleView: UILabel = UILabel(frame: .zero)
    let descriptionLabelView: UILabel = UILabel(frame: .zero)
    
    let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(thumbnailView)
        self.contentView.addSubview(durationLabel)
        
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
        
        durationLabel.numberOfLines = 1
        durationLabel.backgroundColor = .black
        durationLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        durationLabel.textColor = .white
        durationLabel.text = "0:00:00"
        durationLabel.textAlignment = .center
        durationLabel.snp.makeConstraints { make in
            make.right.equalTo(self.contentView).inset(10)
            make.bottom.equalTo(thumbnailView).inset(10)
            make.width.greaterThanOrEqualTo(10)
            make.height.equalTo(20)
        }
        
        durationLabel.textEdgeInsets = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)
        durationLabel.clipsToBounds = true
        durationLabel.layer.cornerRadius = 5.0
        
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
        durationLabel.text = toSimplifyDuration(item.contentDetails.duration)
        durationLabel.sizeToFit()
    }
    
    func toSimplifyDuration(_ string: String) -> String {
        var convertedDuration: String = ""
        string.reversed().forEach {
            c in
            if c == "S" {
                //continue
            }
            else if c == "M" || c == "H" {
                convertedDuration = ":" + convertedDuration
            }
            else {
                convertedDuration = "\(c)" + convertedDuration
            }
        }
        convertedDuration.removeFirst(2)
        
        if !convertedDuration.contains(":") {
            convertedDuration = "0:" + convertedDuration
        }
        
        return convertedDuration
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
