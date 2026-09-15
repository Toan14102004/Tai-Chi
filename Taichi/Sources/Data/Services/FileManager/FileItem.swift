//
//  FileItem.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/3/25.
//

import Combine
import Foundation
import UniformTypeIdentifiers

struct FileItem: Hashable, Codable {
    let id: UUID = .init()
    var name: String
    var isDirectory: Bool
    var createTime: Double
    var url: URL
    var children: [FileItem]
    var selected: Bool
    var metaData: [String: String] = [:]

    // Tính toán các giá trị
    var countFile: Int { children.count { !$0.isDirectory } }
    var selectedFiles: [FileItem] { children.filter { !$0.isDirectory && $0.selected } }
    var selectedFolder: [FileItem] { children.filter { $0.isDirectory && $0.selected } }

    var pdfSummary: String {
        metaData["summary"] ?? ""
    }

    /// Short path relative to documents directory
    var shortPath: String {
        let documentsPath = URL.documentUrl.path
        let fullPath = url.path
        if fullPath.hasPrefix(documentsPath) {
            let relativePath = String(fullPath.dropFirst(documentsPath.count))
            return relativePath.hasPrefix("/") ? String(relativePath.dropFirst()) : relativePath
        }
        return name
    }

    init(
        name: String,
        isDirectory: Bool,
        createTime: Double,
        lastModified _: Double,
        url: URL,
        children: [FileItem],
        selected: Bool
    ) {
        self.name = name
        self.isDirectory = isDirectory
        self.createTime = createTime
        self.url = url
        self.children = children
        self.selected = selected
    }

    // Khởi tạo từ thư mục
    init?(from folder: String) {
        let url = URL.documentUrl.appendingPathComponent(folder, isDirectory: true)
        self.init(from: url)
    }

    // Khởi tạo từ URL
    init?(from url: URL) {
        self.url = url
        name = url.lastPathComponent
        let manager = FileManager.default

        if url.isExists {
            isDirectory = url.isDirectory
            if let att = try? manager.attributesOfItem(atPath: url.path),
               let date = att[FileAttributeKey.creationDate] as? NSDate {
                createTime = date.timeIntervalSince1970
            } else {
                createTime = Date().timeIntervalSince1970
            }
            selected = false
            if isDirectory {
                if let items = try? manager.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: .skipsSubdirectoryDescendants
                ) {
                    children = items.compactMap { FileItem(from: $0) }.sorted(by: >)
                } else {
                    children = []
                }
            } else {
                do {
                    let data = try url.extendedAttribute(forKey: "summary")
                    let summary = String(data: data, encoding: .utf8) ?? ""
                    metaData["summary"] = summary
                } catch {}
                children = []
            }
        } else {
            do {
                try manager.createDirectory(at: url, withIntermediateDirectories: true)
                isDirectory = true
                createTime = Date().timeIntervalSince1970
                children = []
                selected = false
            } catch {
                return nil
            }
        }
    }

    // Khởi tạo từ short path (relative to documents directory)
    init?(fromShortPath shortPath: String) {
        let fullURL = URL.documentUrl.appendingPathComponent(shortPath)
        self.init(from: fullURL)
    }

    /// Create FileItem from short path (relative to documents directory)
    /// Example: "Image/Image.txt" creates Image.txt file in Image folder
    static func create(from shortPath: String) -> FileItem? {
        let fullURL = URL.documentUrl.appendingPathComponent(shortPath)
        return FileItem(from: fullURL)
    }

    /// Create file from short path with content
    /// Example: "Image/Image.txt" creates Image.txt file in Image folder with given content
    static func createFile(from shortPath: String, content: Data? = nil) -> FileItem? {
        let fullURL = URL.documentUrl.appendingPathComponent(shortPath)
        let manager = FileManager.default

        // Create parent directories if they don't exist
        let parentURL = fullURL.deletingLastPathComponent()
        if !parentURL.isExists {
            do {
                try manager.createDirectory(at: parentURL, withIntermediateDirectories: true)
            } catch {
                print("Failed to create parent directory: \(error)")
                return nil
            }
        }

        // Create the file if it doesn't exist
        if !fullURL.isExists {
            do {
                if let content {
                    try content.write(to: fullURL)
                } else {
                    try Data().write(to: fullURL)
                }
            } catch {
                print("Failed to create file: \(error)")
                return nil
            }
        }

        return FileItem(from: fullURL)
    }

    /// Create file from short path with string content
    static func createFile(from shortPath: String, content: String, encoding: String.Encoding = .utf8) -> FileItem? {
        guard let data = content.data(using: encoding) else {
            print("Failed to convert string to data with encoding: \(encoding)")
            return nil
        }
        return createFile(from: shortPath, content: data)
    }
}

extension FileItem: Comparable {
    static func < (lhs: FileItem, rhs: FileItem) -> Bool { lhs.createTime < rhs.createTime }

    static func <= (lhs: FileItem, rhs: FileItem) -> Bool { lhs.createTime <= rhs.createTime }

    static func >= (lhs: FileItem, rhs: FileItem) -> Bool { lhs.createTime >= rhs.createTime }

    static func > (lhs: FileItem, rhs: FileItem) -> Bool { lhs.createTime > rhs.createTime }

    static func == (lhs: FileItem, rhs: FileItem) -> Bool { lhs.createTime == rhs.createTime }
}
