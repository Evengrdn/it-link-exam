//
//  ViewController.swift
//  it-link-exam
//
//  Created by Maksim Kuznecov on 02.10.2023.
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    private let viewModel = MainViewModel()
    
    private lazy var itemsPerRow: CGFloat = 3
    let sectionInsets = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    
    private lazy var colelctionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collView.showsVerticalScrollIndicator = false
        collView.delegate = self
        collView.dataSource = self
        return collView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareView()
        makeConstraints()
        Task{
            await viewModel.fetchImages()
            colelctionView.reloadData()
        }
        
        colelctionView.register(ImagePreviewCollectionCell.self, forCellWithReuseIdentifier: "ImagePreviewCollectionCell")
        setCollectionLayoutFlow()
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setCollectionLayoutFlow()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            Task{
                viewModel.images = []
                colelctionView.reloadData()
                await viewModel.refreshImagesWithCache()
                colelctionView.reloadData()
            }
        }
    }
    
    func prepareView() {
        title = "Main"
        view.backgroundColor = .systemBackground
        view.addSubview(colelctionView)
        colelctionView.backgroundColor = .systemBackground
    }
    
    func makeConstraints() {
        colelctionView.snp.makeConstraints { make in
            make.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
    
    func setCollectionLayoutFlow() {
        colelctionView.collectionViewLayout.invalidateLayout()
        if isOrientationLandscape() {
            itemsPerRow = 5
        } else {
            itemsPerRow = 3
        }
        
    }
    
    func isOrientationLandscape() -> Bool  {
        UIDevice.current.orientation.isLandscape
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let padding = sectionInsets.left + sectionInsets.right
        let availableWidth = collectionView.bounds.width
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem - padding, height: widthPerItem - padding)
        
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ImageDetailViewController(imageWrapp: viewModel.images[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePreviewCollectionCell", for: indexPath) as! ImagePreviewCollectionCell
        let image = UIImage(contentsOfFile: viewModel.images[indexPath.row].fullPreview)
        cell.configureCell(image: image)
        return cell
        
    }
    
    
}
