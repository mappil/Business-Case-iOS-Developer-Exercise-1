//
//  Extensions+UIImageView.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import UIKit

private let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            self.image = cachedImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            
            imageCache.setObject(image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
