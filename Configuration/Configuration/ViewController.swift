//
//  ViewController.swift
//  Configuration
//
//  Created by nika razmadze on 02.08.25.
//

import UIKit

final class GalleryViewController: UICollectionViewController {
    
    private let images = BundleLoader.loadConfiguredImages()
    private let columns = BundleLoader.sharedConfig.gallery.columns
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UICollectionViewCell.self,
                                forCellWithReuseIdentifier: "cell")
        navigationController?.navigationBar.tintColor =
            BundleLoader.color(from: BundleLoader.sharedConfig.theme.tintColorHex)
    }
    
    // MARK: - Data source
    
    override func collectionView(_ cv: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    override func collectionView(_ cv: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cv.dequeueReusableCell(withReuseIdentifier: "cell",
                                          for: indexPath)
        let imageView = UIImageView(image: images[indexPath.item])
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(imageView)
        imageView.frame = cell.contentView.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return cell
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let totalSpacing = layout.minimumInteritemSpacing * CGFloat(columns - 1)
        let width = (view.bounds.width - totalSpacing) / CGFloat(columns)
        layout.itemSize = CGSize(width: width, height: width)
    }
}


// MARK: - Codable structures

struct AppConfig: Codable {
    let gallery: GalleryConfig
    let theme: ThemeConfig
}

struct GalleryConfig: Codable {
    let imageNames: [String]
    let displayMode: DisplayMode
    let columns: Int
    
    enum DisplayMode: String, Codable {
        case grid, carousel
    }
}

struct ThemeConfig: Codable {
    let tintColorHex: String
}


enum BundleLoader {
    
    static let sharedConfig: AppConfig = {
        guard
            let url = Bundle.main.url(forResource: "AppConfig", withExtension: "json"),
            let data = try? Data(contentsOf: url)
        else {
            fatalError("🛑 AppConfig.json missing from bundle.")
        }
        do {
            return try JSONDecoder().decode(AppConfig.self, from: data)
        } catch {
            fatalError("🛑 JSON parsing failed: \(error)")
        }
    }()
    
    static func color(from hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized.removeFirst(hexSanitized.hasPrefix("#") ? 1 : 0)
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >>  8) / 255
        let b = CGFloat( rgb & 0x0000FF       ) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
    
    static func loadConfiguredImages() -> [UIImage] {
        sharedConfig.gallery.imageNames
            .compactMap { UIImage(named: $0) }
    }
}


