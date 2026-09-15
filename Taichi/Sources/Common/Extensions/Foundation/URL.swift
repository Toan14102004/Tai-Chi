//
//  URL.swift
//  Taichi
//
//  Created by Toan Nguyen on 16/3/25.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    static var documentUrl: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    static var cacheUrl: URL {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return paths[0]
    }

    var filename: String {
        deletingPathExtension().lastPathComponent
    }

    var nonExistsFile: URL {
        var url = appendingPathComponent(UUID().uuidString)
        while FileManager.default.fileExists(atPath: url.path) {
            url = appendingPathComponent(UUID().uuidString)
        }
        return url
    }

    var isExists: Bool {
        FileManager.default.fileExists(atPath: path)
    }

    var isDirectory: Bool {
        var isDirectory: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
        return exists && isDirectory.boolValue
    }

    init?(string: String?) {
        if let string {
            self.init(string: string)
        } else {
            return nil
        }
    }

    func nextFolder(name: String) -> URL {
        let validName = name.convertToValidFileName()
        var url = appendingPathComponent(validName, isDirectory: true)
        var index = 0
        var newName = validName
        while url.isExists {
            index += 1
            newName = "\(validName)_(\(index))"
            url = appendingPathComponent(newName, isDirectory: true)
        }
        return url
    }

    func nextFile(name: String, type: UTType) -> URL {
        let validName = name.convertToValidFileName()
        var url = appendingPathComponent(validName, isDirectory: false).appendingPathExtension(for: type)
        var index = 0
        var newName = validName
        while url.isExists {
            index += 1
            newName = "\(validName)_(\(index))"
            url = appendingPathComponent(newName, isDirectory: false).appendingPathExtension(for: type)
        }
        return url
    }

    var utType: UTType {
        if let typeIdentifier = try? resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier,
           let utType = UTType(typeIdentifier) {
            return utType
        }
        return .data // Default type
    }

    static func documentsDirectory() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        .appendingPathComponent("Media Vault", isDirectory: true)
        .appendingPathComponent("Wireless Transfer", isDirectory: true)
    }

    func visibleContents() throws -> [URL] {
        try FileManager.default.contentsOfDirectory(
            at: self,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        )
    }
}

extension URL {
    /// Set custom attribute (key-value) cho file
    func setExtendedAttribute(value: Data, forKey key: String) throws {
        try withUnsafeFileSystemRepresentation { fileSystemPath in
            guard let path = fileSystemPath else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(EFAULT))
            }
            let result = setxattr(path, key, (value as NSData).bytes, value.count, 0, 0)
            if result != 0 {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }
    }

    /// Get custom attribute (key-value) của file
    func extendedAttribute(forKey key: String) throws -> Data {
        try withUnsafeFileSystemRepresentation { fileSystemPath in
            guard let path = fileSystemPath else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(EFAULT))
            }

            // Lấy độ dài value
            let length = getxattr(path, key, nil, 0, 0, 0)
            if length < 0 {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }

            // Lấy dữ liệu thật
            var data = Data(count: length)
            let result = data.withUnsafeMutableBytes { buffer in
                getxattr(path, key, buffer.baseAddress, length, 0, 0)
            }
            if result < 0 {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }

            return data
        }
    }

    /// Remove custom attribute
    func removeExtendedAttribute(forKey key: String) throws {
        try withUnsafeFileSystemRepresentation { fileSystemPath in
            guard let path = fileSystemPath else {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(EFAULT))
            }
            let result = removexattr(path, key, 0)
            if result != 0 {
                throw NSError(domain: NSPOSIXErrorDomain, code: Int(errno))
            }
        }
    }
}
