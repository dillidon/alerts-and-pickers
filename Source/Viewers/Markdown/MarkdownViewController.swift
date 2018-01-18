import UIKit

extension UIAlertController {
    
    /// Add a markdown Viewer
    ///
    /// - Parameters:
    ///   - config: view configuration
    
    func addMarkdownViewer(config: MarkdownViewController.Config? = nil) {
        let textViewer = MarkdownViewController(config: config)
        set(vc: textViewer)
    }
}

final class MarkdownViewController: UIViewController {
    
    public typealias Config = (MarkdownView) -> Swift.Void
    
    struct ui {
        static let height: CGFloat = UIScreen.main.bounds.height * 0.8
    }
    
    fileprivate lazy var indicatorView: UIActivityIndicatorView = {
        $0.color = .lightGray
        return $0
    }(UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge))
    
    fileprivate lazy var mardownView: MarkdownView = MarkdownView()
    
    fileprivate var config: Config?
    
    init(config: Config? = nil) {
        Log("-1-")
        self.config = config
        super.init(nibName: nil, bundle: nil)
        Log("-2-")
        
        mardownView.onRendered = { [weak self] height in
            DispatchQueue.main.async {
                self?.indicatorView.stopAnimating()
                self?.preferredContentSize.height = height
                self?.view.setNeedsLayout()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log("has deinitialized")
    }
    
    override func loadView() {
        view = mardownView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(indicatorView)
        Log("---")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        indicatorView.startAnimating()
        config?(mardownView)
        Log("---")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        indicatorView.center = view.center
    }
}
