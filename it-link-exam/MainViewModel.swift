//
//  MainViewModel.swift
//  it-link-exam
//
//  Created by Maksim Kuznecov on 03.10.2023.
//

import Foundation
import UIKit

/// Обертка для сохранения пути до оригинала и превью картинки
struct CachedImagePathWrap: Codable {
    
    /// Относительная ссылка на превью картинки 150x150
    let preview: String
    
    /// Относительная ссылка на оригинал картинки
    let origin: String
    
    /// Полный путь до оригинала
    var fullOrigin: String {
        getAbsolutePath() + origin
    }
    
    /// Полный путь до превью
    var fullPreview: String {
        getAbsolutePath() + preview
    }
    
    /// Получение полного пути
    /// - Returns: Путь
    private func getAbsolutePath() -> String {
        let path = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        guard let path = path else {
            return ""
        }
        return path.appending(path: CacheManager.cachedFolder).path()
    }
}

class MainViewModel {
    
    /// Массив оберток с путями
    var images: [CachedImagePathWrap] = []
    
    /// Менеджер для работы с сетью
    let networkManager: ItLinkNetwork = NetworkManager()
    
    /// Запрос картинок
    func fetchImages() async {
        do {
            let imageUrls = try await networkManager.fetchImageLinkResource()
            images = try await networkManager.fetchImages(urls: imageUrls)
        }catch(let error) {
            print(error.localizedDescription)
        }
    }
    
    /// Метод очистки
    func refreshImagesWithCache() async {
        images = await networkManager.refreshImages()
    }
}
