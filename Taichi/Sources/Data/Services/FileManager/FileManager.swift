//
//  FileManager.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/3/25.
//

import Combine
import Foundation
import UniformTypeIdentifiers
import UIKit

class FileStorageManager: ObservableObject {
    @Published var imageFolder: FileItem = .init(from: "Image Folder")!
    @Published var videoFolder: FileItem = .init(from: "Video Folder")!

    /// Create Folder in Folder
    /// - Parameters:
    ///   - name: Name for new Folder
    ///   - parentFolder: Parent Folder
    /// - Returns: New folder
    func createFolder(name: String, in parentFolder: FileItem) -> AnyPublisher<FileItem, FileError> {
        guard parentFolder.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let childURL = parentFolder.url.nextFolder(name: trimmedName)

        if let childItem = FileItem(from: childURL) {
            return Just(childItem)
                .setFailureType(to: FileError.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: FileError.fileModelCreationFailed(url: childURL)).eraseToAnyPublisher()
    }

    /// Create new file from data in parent folder
    /// - Parameters:
    ///   - name: File name
    ///   - data: data for new file
    ///   - type: type for new file
    ///   - parentFolder: parent folder
    /// - Returns: New file
    func createFile(
        name: String? = nil,
        from data: Data,
        type: UTType,
        in parentFolder: FileItem,
        metaData: [String: String] = [:]
    ) -> AnyPublisher<FileItem, FileError> {
        guard parentFolder.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd_HH-mm-ss"
        let fileName = name ?? "File_\(formatter.string(from: Date()))"
        let childURL = parentFolder.url.nextFile(name: fileName, type: type)

        do {
            try data.write(to: childURL)
            if !metaData.isEmpty {
                try metaData.forEach { key, value in
                    try childURL.setExtendedAttribute(value: Data(value.utf8), forKey: key)
                }
            }
            if let childItem = FileItem(from: childURL) {
                return Just(childItem)
                    .setFailureType(to: FileError.self)
                    .eraseToAnyPublisher()
            }
            return Fail(error: FileError.fileModelCreationFailed(url: childURL)).eraseToAnyPublisher()

        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Save a food image into the dedicated image folder and return the created FileItem
    func saveTaichiImage(_ image: UIImage, name: String? = nil) -> AnyPublisher<FileItem, FileError> {
        // Prefer JPEG for smaller size; fall back to PNG if needed
        guard let data = image.jpegData(compressionQuality: 0.9) ?? image.pngData() else {
            let error = NSError(domain: "FileStorageManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode image data"])
            return Fail(error: FileError.unowned(error: error)).eraseToAnyPublisher()
        }

        return createFile(
            name: name,
            from: data,
            type: .jpeg,
            in: imageFolder
        )
    }

    /// Copy file from url to parent folder
    /// - Parameters:
    ///   - url: url to that file
    ///   - name: name for new file
    ///   - parentFolder: parent folder
    /// - Returns: New file
    func copyFile(from url: URL, name: String? = nil, to parentFolder: FileItem) -> AnyPublisher<FileItem, FileError> {
        // Try to access security-scoped resource, but don't fail if it's not available
        // (e.g., for files already in app's sandbox)
        let hasSecurityScope = url.startAccessingSecurityScopedResource()
        defer {
            if hasSecurityScope {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        guard parentFolder.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }

        let fileName = name ?? url.deletingPathExtension().lastPathComponent
        let destinationURL = parentFolder.url.nextFile(name: fileName, type: url.utType)
        let fileManager = FileManager.default

        do {
            try fileManager.copyItem(at: url, to: destinationURL)
            try fileManager.setAttributes([FileAttributeKey.creationDate: NSDate()], ofItemAtPath: destinationURL.path)
            if let childItem = FileItem(from: destinationURL) {
                return Just(childItem)
                    .setFailureType(to: FileError.self)
                    .eraseToAnyPublisher()
            }
            return Fail(error: FileError.fileModelCreationFailed(url: destinationURL)).eraseToAnyPublisher()
        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Rename for file
    /// - Parameters:
    ///   - name: New name
    ///   - item: File want rename
    /// - Returns: File with new name
    func rename(name: String, for item: FileItem) -> AnyPublisher<FileItem, FileError> {
        let toName = name.trimmingCharacters(in: .whitespacesAndNewlines).convertToValidFileName()
        let destinationURL = item.url.isDirectory
            ? item.url.deletingLastPathComponent().nextFolder(name: toName)
            : item.url.deletingLastPathComponent().nextFile(name: toName, type: item.url.utType)

        var newItem = item
        do {
            try FileManager.default.moveItem(at: item.url, to: destinationURL)
            // Move sidecar metadata file as well if present
            if !item.isDirectory {
                let oldMeta = item.url.appendingPathExtension("meta").appendingPathExtension("json")
                let newMeta = destinationURL.appendingPathExtension("meta").appendingPathExtension("json")
                if FileManager.default.fileExists(atPath: oldMeta.path) {
                    try? FileManager.default.moveItem(at: oldMeta, to: newMeta)
                }
            }

            newItem.url = destinationURL
            newItem.name = destinationURL.lastPathComponent
            newItem.children.removeAll()

            if newItem.isDirectory {
                let items = try FileManager.default.contentsOfDirectory(
                    at: destinationURL,
                    includingPropertiesForKeys: nil,
                    options: .skipsSubdirectoryDescendants
                )
                newItem.children = items.compactMap { FileItem(from: $0) }
                newItem.children.sort(by: >)
            }

            return Just(newItem)
                .setFailureType(to: FileError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Delete file
    /// - Parameter item: Files to delete
    /// - Returns: Success
    func deleteFile(_ file: FileItem) -> AnyPublisher<Void, FileError> {
        do {
            try FileManager.default.removeItem(at: file.url)
            return Just(())
                .setFailureType(to: FileError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Delete selected file in folder
    /// - Parameter folder: Parent folder
    /// - Returns: folder after delete file
    func deleteSelectedFile(in folder: FileItem) -> AnyPublisher<FileItem, FileError> {
        guard folder.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }
        var newItem = folder
        let filesToDelete = newItem.children.filter { !$0.isDirectory && $0.selected }

        do {
            for file in filesToDelete {
                try FileManager.default.removeItem(at: file.url)
            }
            newItem.children.removeAll { !$0.isDirectory && $0.selected }
            return Just(newItem)
                .setFailureType(to: FileError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Delete selected folder in folder
    /// - Parameter folder: Parent folder
    /// - Returns: Folder after delete
    func deleteSelectedFolder(folder: FileItem) -> AnyPublisher<FileItem, FileError> {
        guard folder.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }
        var newItem = folder
        let filesToDelete = folder.children.filter { $0.isDirectory && $0.selected }

        do {
            for file in filesToDelete {
                try FileManager.default.removeItem(at: file.url)
            }
            newItem.children.removeAll { $0.isDirectory && $0.selected }
            return Just(newItem)
                .setFailureType(to: FileError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Move file to new folder
    /// - Parameters:
    ///   - file: file need move
    ///   - parent: Folder
    /// - Returns: New file in Folder
    func moveFile(from file: FileItem, to parent: FileItem) -> AnyPublisher<FileItem, FileError> {
        guard parent.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }
        let fileName = file.url.deletingPathExtension().lastPathComponent
        let destinationURL = parent.url.nextFile(name: fileName, type: file.url.utType)

        do {
            try FileManager.default.moveItem(at: file.url, to: destinationURL)

            if let newItem = FileItem(from: destinationURL) {
                return Just(newItem)
                    .setFailureType(to: FileError.self)
                    .eraseToAnyPublisher()
            }
            return Fail(error: FileError.fileModelCreationFailed(url: destinationURL)).eraseToAnyPublisher()
        } catch {
            return Fail(error: .unowned(error: error)).eraseToAnyPublisher()
        }
    }

    /// Move multiple file to new folder
    /// - Parameters:
    ///   - files: List file to move
    ///   - parent: New folder
    /// - Returns: New folder with new file
    func moveFile(files: [FileItem], to parent: FileItem) -> AnyPublisher<FileItem, FileError> {
        guard parent.isDirectory else {
            return Fail(error: FileError.notDirectory).eraseToAnyPublisher()
        }
        var parentFile = parent

        let movePublishers = files.map { file in
            moveFile(from: file, to: parentFile)
        }

        return Publishers.MergeMany(movePublishers)
            .handleEvents(receiveOutput: { item in
                parentFile.children.append(item)
            })
            .collect() // Đợi tất cả các file được di chuyển xong
            .map { _ in parentFile }
            .eraseToAnyPublisher()
    }
}
