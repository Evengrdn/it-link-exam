//
//  File.swift
//  it-link-exam
//
//  Created by Maksim Kuznecov on 04.10.2023.
//

import Foundation
import UIKit

/// Политика кеширования (используется сохранение на диск)
protocol ItLinkCachePolicy {
    
    /// Конфигураци кеша
    var cacheConfig: [String: CachedImagePathWrap] { get }
    
    /// Получение картинки из кеша по пути
    /// - Parameter key: URL ключ cacheConfig
    /// - Returns: Обертка с относительным путем до файла
    func fetchImageResource(url key: URL) -> CachedImagePathWrap?
    
    /// Проверка наличия картинки в кеше
    /// - Parameter url: URL для поиска
    /// - Returns: Флаг наличия каринки в кеше
    func isCached(url: URL) -> Bool
    
    /// Загрузка конфигурации с диска
    func loadConfig()
    
    /// Получение пути до кеша
    /// - Returns: Путь
    func getCacheStoreUrl() -> URL?
    
    /// Кеширование изображения
    /// - Parameters:
    ///   - image: Картинка
    ///   - key: URL использется как ключ
    /// - Returns: Обертка с отноистельными путями до картинок
    func cacheImage(image: UIImage, key: URL) -> CachedImagePathWrap
    
    /// Обнолвление файла конфигурации
    func updateConfig()
    
    /// Создание файла конфигурации если его нет
    func createConfigIsNotFound()
    
    /// Сброс кеша
    func resetCache()
}

/// Менеджер реализующий политику кешироавния
final class CacheManager: ItLinkCachePolicy {
    static let cachedFolder = "Images"
    
    var cacheConfig: [String : CachedImagePathWrap] = [:]
    
    func cacheImage(image: UIImage, key: URL) -> CachedImagePathWrap {
        let preview = image.preparingThumbnail(of: .init(width: 150, height: 150))?.pngData()
        let origin = image.pngData()
        let folderName = UUID().uuidString
        let cacheStoreUrl = getCacheStoreUrl()!
        let fullCacheUrl = cacheStoreUrl.appending(path: folderName)
        try? FileManager.default.createDirectory(atPath: fullCacheUrl.path, withIntermediateDirectories: true, attributes: nil)
        try? preview?.write(to: fullCacheUrl.appending(path: "preview.png"))
        try? origin?.write(to: fullCacheUrl.appending(path: "origin.png"))
        let cachedImage = CachedImagePathWrap(preview: "/\(folderName)/preview.png", origin: "/\(folderName)/origin.png")
        
        cacheConfig[key.absoluteString] = cachedImage
        updateConfig()
        return cachedImage
    }
    
    func updateConfig() {
        guard let data = try? JSONEncoder().encode(cacheConfig) else { return }
        
        if let cacheStoreUrl = getCacheStoreUrl() {
            try? data.write(to: cacheStoreUrl.appending(path: "config.json"))
        }
        
    }
    
    
    func getCacheStoreUrl() -> URL? {
        let documentUrl = try? FileManager.default.url(for: .cachesDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
        guard let documentUrl = documentUrl else { return nil }
        if !FileManager.default.fileExists(atPath: documentUrl.appending(path: CacheManager.cachedFolder).path) {
            try? FileManager.default.createDirectory(atPath: documentUrl.appending(path: CacheManager.cachedFolder).path, withIntermediateDirectories: true, attributes: nil)
        }
        return documentUrl.appending(path: CacheManager.cachedFolder)
    }
    
    
    func isCached(url: URL) -> Bool {
        return cacheConfig.contains { (key: String, _) in
            key == url.absoluteString
        }
    }
    
    func createConfigIsNotFound() {
        let documentUrl = getCacheStoreUrl()
        guard let documentUrl = documentUrl else { return }
        
        if !FileManager.default.fileExists(atPath: documentUrl.appending(path: "config.json").path) {
            FileManager.default.createFile(atPath: documentUrl.appending(path: "config.json").path, contents: nil)
        }
    }
    
    func loadConfig() {
        guard let cacheStoreUrl = getCacheStoreUrl() else {
            return
        }
        guard let dataFromJsonInLocalStorage = try? Data(contentsOf: cacheStoreUrl.appending(path: "config.json")) else {
            return
        }
        let cachecConfig = try? JSONDecoder().decode([String: CachedImagePathWrap].self, from: dataFromJsonInLocalStorage)
        if let cachecConfig = cachecConfig {
            cacheConfig = cachecConfig
        }
        
    }
    
    func fetchImageResource(url key: URL) -> CachedImagePathWrap? {
        guard let cachedWrap = cacheConfig[key.absoluteString] else {
            return nil
        }
        return cachedWrap
    }
    
    func resetCache() {
        let documentUrl = getCacheStoreUrl()
        cacheConfig = [:]
        guard let documentUrl = documentUrl else { return }
        try? FileManager.default.removeItem(at: documentUrl)
    }
    
    
}
