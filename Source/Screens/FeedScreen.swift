import UIKit
import Combine
import SwiftUI
import CoreData

class FeedScreen: UIViewController {
    private var userId: String?
    private var isLoading = false
    private let feedAPI = FeedAPI()
    private var blurEffectView: UIVisualEffectView?
    private var circleViews: [IndexPath: UIView] = [:]
    
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // MARK: Constants
    private enum Constants {
        static let lineSpacing: CGFloat = 128
        static let sectionInset: UIEdgeInsets = .init(top: 40, left: 214 - 48, bottom: 0, right: 0)
    }
    
    // MARK: Typealiases
    typealias DataSource = UICollectionViewDiffableDataSource<Int, APIEntry>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, APIEntry>
    
    // MARK: UI properties
    private let transitionAnimator = SharedTransitionAnimator()
    private lazy var dataSource = DataSource(collectionView: collectionView, cellProvider: cellProvider)
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private lazy var layout = UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = Constants.lineSpacing
        $0.sectionInset = Constants.sectionInset
    }
    
    
    // MARK: Private properties
    private var cancellables = Set<AnyCancellable>()
    private var selectedIndexPath: IndexPath? = nil
    private var entries = [APIEntry]() {
        didSet { updateCollectionView() }
    }
    
    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        setupUI()
        observeEntries()
        observeLoading()
        
        if let userId = userId {
            feedAPI.userId = userId
            feedAPI.fetchEntries()
        } else {
            print("User ID is nil in FeedScreen")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
    }
}

// MARK: - Helpers
extension FeedScreen {
    private func setupUI() {
        setupCollectionView()
    }
    
    private func observeEntries() {
        feedAPI.$entries.sink { [weak self] newEntries in
            self?.entries = newEntries
        }.store(in: &cancellables)
    }
    
    private func observeLoading() {
        feedAPI.$isLoading
            .sink { [weak self] isLoading in
                self?.isLoading = isLoading
            }
            .store(in: &cancellables)
    }
    


    private func setupCollectionView() {
        collectionView.then {
            view.addSubview($0)
            $0.register(FeedCell.self)
            $0.dataSource = dataSource
            $0.delegate = self
            $0.delaysContentTouches = false
            $0.backgroundColor = .clear
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.bottom == view.bottomAnchor
            $0.top == view.topAnchor
        }

        blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterialDark))
        blurEffectView?.then {
            $0.isUserInteractionEnabled = false
            $0.translatesAutoresizingMaskIntoConstraints = false
            collectionView.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor
            $0.trailing == view.trailingAnchor
            $0.top == view.topAnchor
            $0.bottom == view.bottomAnchor
        }

        let dashView = UIHostingController(rootView: DashView(isLoading: Binding(
            get: { self.feedAPI.isLoading },
            set: { self.feedAPI.isLoading = $0 }
        ))).view
        dashView?.then {
            $0.backgroundColor = .clear
            $0.translatesAutoresizingMaskIntoConstraints = false
            collectionView.addSubview($0)
        }.layout {
            $0.leading == view.leadingAnchor + 38
            $0.top == view.topAnchor + 72
        }
    }
}

// MARK: - UICollectionView helpers
extension FeedScreen {
    private func updateCollectionView() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(entries, toSection: 0)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private var cellProvider: DataSource.CellProvider {
        { [weak self] collectionView, indexPath, entry in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeedCell", for: indexPath) as? FeedCell else {
                fatalError("Cannot create new cell")
            }
            
            // Create the entry card
            cell.setup(with: entry)
            cell.layer.zPosition = 1

            let screenWidth = UIScreen.main.bounds.width
            let cellFrame = cell.frame
            let circleFrame = CGRect(x: cellFrame.origin.x - 184, y: cellFrame.origin.y - 64, width: screenWidth, height: screenWidth)

            // Create a circle view if not already in dictionary.
            if let circleView = self?.circleViews[indexPath] {
                circleView.frame = circleFrame
            } else {
                let circleView = CircleView(hexColor: entry.sound.appleData?.artworkBgColor ?? "#FFF", width: screenWidth, height: screenWidth, startRadius: 0, endRadius: screenWidth)
                let circleHost = UIHostingController(rootView: circleView)

                guard let circleHostView = circleHost.view else { return cell }
                circleHostView.backgroundColor = .clear
                circleHostView.isUserInteractionEnabled = false

                if let blurEffectView = self?.blurEffectView {
                    collectionView.insertSubview(circleHostView, belowSubview: blurEffectView)
                }
                circleHostView.frame = circleFrame

                // Store the circle view in the dictionary
                self?.circleViews[indexPath] = circleHostView
            }

            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension FeedScreen: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let entry = entries[indexPath.item]
        let viewController = EntryScreen(entry: entry)
        navigationController?.pushViewController(viewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == entries.count - 1 {
            feedAPI.fetchEntries()
        }
    }
}



// MARK: - UICollectionViewDelegateFlowLayout methods

extension FeedScreen: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 216, height: 304)
    }
}

// MARK: - UINavigationControllerDelegate
extension FeedScreen: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC is Self, toVC is EntryScreen {
            transitionAnimator.transition = .push
            return transitionAnimator
        }
        if toVC is Self, fromVC is EntryScreen {
            transitionAnimator.transition = .pop
            return transitionAnimator
        }
        return nil
    }
}

// MARK: - SharedTransitioning

extension FeedScreen: SharedTransitioning {
    var sharedFrame: CGRect {
        guard let selectedIndexPath,
              let cell = collectionView.cellForItem(at: selectedIndexPath),
              let frame = cell.frameInWindow else { return .zero }
        return frame
    }

    func prepare(for transition: SharedTransitionAnimator.Transition) {
        guard transition == .pop, let selectedIndexPath else { return }
        collectionView.verticalScrollItemVisible(at: selectedIndexPath, with: 40, animated: false)
    }
}
