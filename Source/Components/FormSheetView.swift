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

class FormSheetViewController<Sound: Soundable>: UIViewController, UITextViewDelegate {
    var sound: Sound
    var artworkURL: URL?
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let textView = UITextView()
    
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
        
        setupImageView()
        setupLabels()
        setupTextView()
        layoutUI()
        
        if let url = artworkURL {
            loadImage(from: url)
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
}
