//
//  UIImageView+load.swift
//  GitSearchDemo
//
//  Created by Sergei Morozov on 20.09.21.
//

import UIKit


// will be better to use KingFisher lib instead of this code

extension UIImageView {
    func load(url: URL?){
        DispatchQueue.global().async { [weak self] in
            guard let imageURl = url else {
                return
            }
            func setImage(image:UIImage?) {
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
            if let data = try? Data(contentsOf: imageURl), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    setImage(image: image)
                }
            }else {
                setImage(image: nil)
            }
        }
    }
}
