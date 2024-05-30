import UIKit
import SwiftUI

struct FormSheetWrapper<Sound: Soundable>: UIViewControllerRepresentable {
    var sound: Sound
    var artworkURL: URL?
    
    func makeUIViewController(context: Context) -> FormSheetViewController<Sound> {
        FormSheetViewController(sound: sound, artworkURL: artworkURL)
    }
    
    func updateUIViewController(_ uiViewController: FormSheetViewController<Sound>, context: Context) {}
}

class FormSheetViewController<Sound: Soundable>: UIViewController, UITextViewDelegate, SearchBarDelegate {

    func searchBar(_ searchBar: NavBar, textDidChange searchText: String) {
        
    }

    
    
    var sound: Sound
    var artworkURL: URL?
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textView = UITextView()
    private var dialView: DialView?

    init(sound: Sound, artworkURL: URL?) {
        self.sound = sound
        self.artworkURL = artworkURL
        super.init(nibName: nil, bundle: nil)
        print("Sound instance: \(sound)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        if let navBar = NavBarManager.shared.navBar {
            navBar.customDelegate = self
        }
        
        setupImageView()
        setupLabels()
        setupTextView()
        setupGesture()
        layoutUI()
        
        if let url = artworkURL {
            loadImage(from: url)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if NavBarManager.shared.navBar?.setSearchBarViewHeight(animated: true) == nil {
            print("NavBar instance not found")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         
         if NavBarManager.shared.navBar?.setSearchBarViewHeight(animated: true) == nil {
             print("NavBar instance not found")
         }
     }

    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        view.addSubview(imageView)
    }
    
    private func setupLabels() {
        titleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
        
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        if let song = sound as? Song {
            subtitleLabel.text = "sdjnjsad"
            titleLabel.text = song.attributes.name
        } else if let album = sound as? Album {
            subtitleLabel.text = album.attributes.artistName
            titleLabel.text = album.attributes.name
        }
    }
    
    private func setupTextView() {
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.backgroundColor = .clear
        view.addSubview(textView)
    }
    
    private func layoutUI() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(equalToConstant: 350),
            
            subtitleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func loadImage(from url: URL) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
        task.resume()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.5) {
            self.textView.invalidateIntrinsicContentSize()
        }
    }
    
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        imageView.addGestureRecognizer(longPressGesture)
        imageView.isUserInteractionEnabled = true
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: view)
        switch gesture.state {
        case .began:
            showDial(at: location)
        case .changed:
            dialView?.updateSelectedAction(at: gesture.location(in: dialView))
        case .ended:
            if let selectedAction = dialView?.selectedAction {
                performAction(selectedAction)
            }
            hideDial()
        default:
            break
        }
    }

    private func animateDialIn(_ dial: DialView) {
        dial.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        dial.alpha = 0
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.75,
                       initialSpringVelocity: 1,
                       options: .curveEaseInOut,
                       animations: {
                           dial.transform = .identity
                           dial.alpha = 1
                       },
                       completion: nil)
    }

    private func showDial(at point: CGPoint) {
        let dial = DialView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        dial.center = point
        view.addSubview(dial)
        dialView = dial
        animateDialIn(dial)
    }

    private func animateDialOut(_ dial: DialView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
                           dial.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                           dial.alpha = 0
                       },
                       completion: { _ in
                           completion()
                       })
    }

    private func hideDial() {
        if let dial = dialView {
            animateDialOut(dial) {
                dial.removeFromSuperview()
                self.dialView = nil
            }
        }
    }

    private func performAction(_ action: Int) {
        switch action {
        case 0:
            print("Pin action selected")
        case 1:
            print("Save action selected")
        case 2:
            print("Share action selected")
        default:
            break
        }
    }
}
