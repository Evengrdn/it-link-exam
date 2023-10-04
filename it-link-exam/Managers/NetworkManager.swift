//
//  NetworkManager.swift
//  it-link-exam
//
//  Created by Maksim Kuznecov on 04.10.2023.
//

import Foundation
import UIKit

enum NetworkPath: String {
    case itLinkImageResource = "https://it-link.ru/test/images.txt"
    
    var asURL: URL? {
        return URL(string: self.rawValue)
    }
}

protocol ItLinkNetwork {
    
    /// Менеджер для взаимодействия с кешем
    var cache: ItLinkCachePolicy { get }
    
    /// Получение файла с набором ссылок на картинки
    /// - Returns: Маасив ссылок на картинки
    func fetchImageLinkResource() async throws -> [URL]
    
    /// Запрос картинок
    /// - Parameter urls: Массив ссылок на картинки
    /// - Returns: Массив оберток с относительными путями до картинок в кеше
    func fetchImages(urls: [URL]) async throws -> [CachedImagePathWrap]
    
    /// Запрос картинок c обнолвением кеша
    /// - Parameter urls: Массив ссылок на картинки
    /// - Returns: Массив оберток с относительными путями до картинок в кеше
    func refreshImages() async -> [CachedImagePathWrap]
}

final class NetworkManager: ItLinkNetwork {

    var cache: ItLinkCachePolicy = CacheManager()
    
    func fetchImages(urls: [URL]) async throws -> [CachedImagePathWrap] {
        var cahcedImages: [CachedImagePathWrap] = []
        cache.loadConfig()
        for url in urls {
            if cache.isCached(url: url) {
                cahcedImages.append(cache.fetchImageResource(url: url)!)
            } else {
                let task = Task<UIImage?, Error> {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    
                    guard let image = UIImage(data: data) else {
                        return nil
                    }
                    return image
                }
                do {
                    if let image = try await task.value {
                        cahcedImages.append(cache.cacheImage(image: image, key: url))
                    }
                } catch {
                    print("error with " + url.absoluteString )
                    throw error
                }
            }
        }
        return cahcedImages
        
    }
    
    func fetchImageLinkResource() async throws -> [URL] {
        guard let url = NetworkPath.itLinkImageResource.asURL else {
            return []
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decodedUrls = String(bytes: data, encoding: .utf8)
        guard let decodedUrls = decodedUrls else { return [] }
        
        return decodedUrls
            .split(separator: "\r\n")
            .compactMap{ urlString in
                if urlString.contains("https://"), let url = URL(string: String(urlString)) {
                    return url
                }
                return nil
            }
    }
    
    func refreshImages() async -> [CachedImagePathWrap] {
        cache.resetCache()
        cache.createConfigIsNotFound()
        do {
            let urls = try await fetchImageLinkResource()
            return try await fetchImages(urls: urls)
        } catch (_) {
            return []
        }
    }
    
}
