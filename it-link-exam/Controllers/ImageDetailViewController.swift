//
//  ImageDetailViewController.swift
//  it-link-exam
//
//  Created by Maksim Kuznecov on 03.10.2023.
//

import UIKit

class ImageDetailViewController: UIViewController {
    
    private var uiImage: UIImageView = UIImageView()
    private var currentScale = 0.0
    private var cacheWrapp: CachedImagePathWrap
    
    init(imageWrapp: CachedImagePathWrap) {
        self.cacheWrapp = imageWrapp
        uiImage.image = UIImage(contentsOfFile: imageWrapp.fullOrigin)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.layer.opacity = 1.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        makeConstraints()
        bindGesture()
    }
    
    private func configureView() {
        view.backgroundColor = .systemBackground
        view.addSubview(uiImage)
        uiImage.contentMode = .scaleAspectFit
        uiImage.isUserInteractionEnabled = true
    }
    
    private func bindGesture() {
        let singleTap = UITapGestureRecognizer()
        singleTap.addTarget(self, action: #selector(singleTapAction))
        singleTap.delaysTouchesBegan = true
        uiImage.addGestureRecognizer(singleTap)
        
        let pinchGesture = UIPinchGestureRecognizer()
        pinchGesture.addTarget(self, action: #selector(pinchGestureAction))
        uiImage.addGestureRecognizer(pinchGesture)
        
        let doubleTap = UITapGestureRecognizer()
        doubleTap.numberOfTapsRequired = 2
        doubleTap.addTarget(self, action: #selector(doubleTapAction))
        doubleTap.delaysTouchesBegan = true
        uiImage.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    private func makeConstraints () {
        uiImage.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.layoutMarginsGuide)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    @objc func singleTapAction() {
        let opacity = navigationController?.navigationBar.layer.opacity
        
        if let opacity = opacity, opacity < 1.0 {
            showNavigation()
        } else {
            hideNavigation()
        }
        
    }
    
    /// Плавное скрытие навигации
    private func hideNavigation() {
        // Если навигациия уже скрыта, прерываем выполнение
        if let opasity = navigationController?.navigationBar.layer.opacity, opasity < 1.0 {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.layer.opacity = 0.0
        }
    }
    
    /// Плавный показ навигации
    private func showNavigation() {
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.layer.opacity = 1.0
        }
    }
    
    @objc func pinchGestureAction(_ gestureRecognizer : UIPinchGestureRecognizer) {
        guard gestureRecognizer.view != nil else { return }
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            // Скрытие навигации при увелечении картинки
            hideNavigation()
            // Если уменьшение картинки и мы достигли исходного увелечения - отключаем уменьшение
            if gestureRecognizer.scale < 1.0, currentScale == 0.0 {
                return
            }
            
            print(gestureRecognizer.scale)
            
            //Если увеличиваем, то складываем. Иначе вычитаем
            if gestureRecognizer.scale > 1.0 {
                currentScale +=  gestureRecognizer.scale - 1.0
            } else {
                currentScale -= 1.0 - gestureRecognizer.scale
            }
            
            // Если мы достигли исходного увелечения, сбрасываем состояние до исходного
            if currentScale < 0.0 {
                currentScale = 0.0
                gestureRecognizer.view?.transform = .identity
                return
            }
            
            gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale))!
            gestureRecognizer.scale = 1.0
            
        }
    }
    
    @objc func doubleTapAction(_ gestureRecognizer : UITapGestureRecognizer ) {
        guard gestureRecognizer.view != nil else { return }
        // Проверка наличия увелчения
        // Если оно есть - сбрасываем
        // Если нет - то установим свое
        if currentScale == 0.0 {
            UIView.animate(withDuration: 0.3) {
                gestureRecognizer.view?.transform = (gestureRecognizer.view?.transform.scaledBy(x: 2.0, y: 2.0))!
                self.currentScale = 2.0
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                gestureRecognizer.view?.transform = .identity
                self.currentScale = 0.0
            }
        }
    }
}
