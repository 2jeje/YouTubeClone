

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    var topView = UIView(frame: .zero)
    var videoTableView = UITableView(frame: .zero)
    
    let disposeBag = DisposeBag()
    
    let viewModel = YouTubeVideoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(topView)
        self.view.addSubview(videoTableView)
        

        let citiesOb: Observable<[YouTubeVideo]> = Observable.of(viewModel.videos)
        citiesOb.bind(to: videoTableView.rx.items(cellIdentifier: "videoCell")) { (index: Int, element: YouTubeVideo, cell: UITableViewCell) in

           // cell.textLabel?.text = element

        }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }

    
    func setupUI() {
        topView.snp.makeConstraints { make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(50)
        }
        topView.backgroundColor = .red
        
        videoTableView.snp.makeConstraints{ make in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        videoTableView.backgroundColor = .black
    }

}


class YouTubeVideoTableViewCell: UITableViewCell {
    
}

class YouTubeVideoViewModel {
    var videos: [YouTubeVideo] = []
    
}

struct YouTubeVideo {
    
}
