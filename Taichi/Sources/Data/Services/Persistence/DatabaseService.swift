//
//  DatabaseService.swift
//  Taichi
//
//  Central database service providing access to all repositories.
//

import CoreData
import CoreDataKit
import Foundation

// MARK: - DatabaseService

final class DatabaseService {

    // MARK: - Initialization

    init(configuration: CoreDataConfiguration) {
        _ = CoreDataStack(configuration: configuration)
    }
    
    // MARK: - Factory Method
    
    /// Create default database service with the app's CoreData model
    /// Create default database service with the app's CoreData model
    static func createDefault() -> DatabaseService {
        let modelName = "data_model_v1"
        
        // Try to load as a bundle (momd) first, then fallback to single file (mom)
        let modelURL =
        Bundle.main.url(forResource: modelName, withExtension: "momd")
        ?? Bundle.main.url(forResource: modelName, withExtension: "mom")
        
        guard let url = modelURL, let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load CoreData model '\(modelName)'")
        }
        
        let config = CoreDataConfiguration(
            modelName: modelName,
            databaseFileName: "taichi.sqlite",
            managedObjectModel: model
        )
        
        return DatabaseService(configuration: config)
    }
}
