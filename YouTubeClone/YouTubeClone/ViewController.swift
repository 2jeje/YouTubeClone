
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher


class ViewController: UIViewController {

    var topView = UIView(frame: .zero)
    var videoTableView = UITableView(frame: .zero)
    
    let disposeBag = DisposeBag()
    
    let viewModel = YouTubeVideoViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(topView)
        self.view.addSubview(videoTableView)
        
        videoTableView.register(YouTubeVideoTableViewCell.self, forCellReuseIdentifier: "videoCell")
        videoTableView.rx.setDelegate(self).disposed(by: disposeBag)
        videoTableView.rowHeight = 280
        
        viewModel.videoSubject.bind(to: videoTableView.rx.items(cellIdentifier: "videoCell", cellType: YouTubeVideoTableViewCell.self)) { (index, element, cell) in
            print("\(element.id)")
            cell.update(url: element.snippet.thumbnails.high.url)
           // cell.textLabel?.text = element

        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchData().subscribe(onSuccess: { response in
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
}



class YouTubeVideoTableViewCell: UITableViewCell {
    let thumbnailView: UIImageView = UIImageView(frame: .zero)
    let videoDescriptionView: UIView = UIView(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(thumbnailView)
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.snp.makeConstraints { make in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.height.equalTo(220)
            
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func update(url: String) {
        thumbnailView.kf.setImage(with: URL(string: url))
    }

    
}

class YouTubeVideoViewModel {
    let disposeBag = DisposeBag()
    
    let videoSubject = BehaviorSubject<[YouTubeVideoItem]>(value: [])
    var videos: [YouTubeVideoItem] = []

    func fetchData() -> Single<YouTubeVideoResponse?>{
        return YouTubeApi.shared.mostPopular().do( onSuccess: { response in
            self.videos = response?.items ?? []
            self.videoSubject.on(.next(self.videos))
        })
    }
    
}

