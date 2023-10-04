//
//  ImagePreviewCollectionCell.swift
//  it-link-exam
//
//  Created by Maksim Kuznecov on 04.10.2023.
//

import Foundation
import UIKit
import SnapKit

class ImagePreviewCollectionCell: UICollectionViewCell {
        
    private var uiImageView = UIImageView()
    
    private var activityIndicator = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
        prepareView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureView() {
        contentView.addSubview(uiImageView)
        contentView.addSubview(activityIndicator)
        activityIndicator.isHidden = true
    }
    
    private func prepareView () {
        activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        uiImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configureCell(image: UIImage?) {
        if let image = image {
            uiImageView.image = image
        } else {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            uiImageView.isHidden = true
        }
       
    }
}
