# GreenEat dev

A comprehensive SwiftUI-based iOS application template that implements Clean Architecture principles with MVVM-C (Model-View-ViewModel-Coordinator) pattern. This project serves as a robust foundation for building scalable iOS applications with modern development practices.

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/nts-sixblack/GreenEat)

## 🚀 Features

### Core Features
- **Clean Architecture Implementation** - Separation of concerns with clear layer boundaries
- **MVVM-C Pattern** - Model-View-ViewModel-Coordinator for better navigation and state management
- **Dependency Injection** - Custom DI container for loose coupling and testability
- **Reactive Programming** - Combine framework for data flow and state management
- **Custom Navigation System** - FlowStack-based navigation with type-safe routing

### Services & Integrations
- **🔐 In-App Purchases (IAP)** - Complete subscription management with SwiftyStoreKit
- **🌐 Network Layer** - Alamofire-based API service with authentication interceptors
- **📁 File Management** - Local file storage and management system
- **💾 Core Data Integration** - Persistent data storage with repository pattern
- **🔔 Push Notifications** - Native APNs remote notification handling
- **🎨 Asset Management** - SwiftGen for type-safe asset and font access
- **📱 Permission Handling** - Centralized user permission management
- **🔧 App Configuration** - Local, code-level flags (`AppFlags`) for Ads/IAP — no remote config server

### Development Tools
- **SwiftGen** - Automatic code generation for assets, fonts, and localizations
- **SwiftLint** - Code style enforcement and best practices
- **CocoaPods** - Dependency management
- **Custom Templates** - Stencil templates for code generation

## 📋 Requirements

- **iOS 15.0+**
- **Xcode 13.0+**
- **Swift 5.5+**
- **SwiftGen 6.6.0+**
- **SwiftLint 0.50.0+**
- **CocoaPods 1.11.0+**

## 📐 Flow Spec

Every screen, its data source, and its navigation — written from the Figma file and checked against
the API: **[`docs/README.md`](docs/README.md)**.

## 🏗️ Project Structure

```
GreenEat/
├── GreenEat.xcworkspace/          # Xcode workspace
├── GreenEat/
│   ├── Enviroments/                       # Build configurations
│   │   ├── Dev.xcconfig                   # Development environment
│   │   └── Release.xcconfig               # Release environment
│   ├── Resources/                         # App resources
│   │   ├── Assets/                        # Asset catalogs
│   │   │   ├── Assets.xcassets           # Main assets
│   │   │   ├── Color.xcassets            # Color definitions
│   │   │   ├── Icon.xcassets             # App icons
│   │   │   └── Image.xcassets            # Images
│   │   ├── Fonts/                        # Custom fonts
│   │   │   └── Roboto/                   # Roboto font family
│   │   ├── Languages/                    # Localization files
│   │   ├── Info.plist                    # App configuration
│   │   └── LaunchScreen.storyboard       # Launch screen
│   └── Sources/                          # Source code
│       ├── Application/                  # App lifecycle & configuration
│       ├── Common/                       # Shared components & utilities
│       ├── Configuration/                # App configuration
│       ├── Data/                         # Data layer (models & services)
│       ├── Generated/                    # SwiftGen generated code
│       ├── Helpers/                      # Helper classes & extensions
│       ├── Injected/                     # Dependency injection
│       ├── Modules/                      # Feature modules (MVVM-C)
│       ├── Utilities/                    # Utility classes
│       └── Views/                        # Reusable UI components
├── Templates/                            # SwiftGen templates
├── Podfile                              # CocoaPods dependencies
├── swiftgen.yml                         # SwiftGen configuration
└── .swiftlint.yml                       # SwiftLint rules
```

## 🏛️ Architecture Overview

### Clean Architecture Layers

1. **Presentation Layer** (`Sources/Modules/`)
   - **Views**: SwiftUI views with declarative UI
   - **ViewModels**: Business logic and state management
   - **Coordinators**: Navigation and flow control

2. **Data Layer** (`Sources/Data/`)
   - **Services**: External data sources (API, Core Data, File System)
   - **Repositories**: Data access abstraction
   - **Models**: Data transfer objects

### MVVM-C Pattern Implementation

```swift
// Example module structure
Modules/Home/
├── HomeView.swift           # SwiftUI View
├── HomeViewModel.swift      # ViewModel with business logic
└── HomeViewCoordinator.swift # Navigation coordinator
```

### Dependency Injection

The project uses a custom DI container (`DIContainer`) that manages:
- **App State**: Global application state
- **Services**: API, File Management, Core Data, etc.
- **User Permissions**: Centralized permission handling

```swift
// Usage example
@Environment(\.injected) private var injected: DIContainer
@Injected var apiService: APIService
```

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:LammaIOS/AIChatbotAssistant_IOS.git
   cd AIChatbotAssistant_IOS
   ```
   
2. **Rename project**
   ```bash
   ./rename.swift "GreenEat" "NewName"
   ```

3. **Install dependencies**
   ```bash
   pod install
   ```

4. **Open workspace**
   ```bash
   open GreenEat.xcworkspace
   ```

5. **Generate code assets**
   ```bash
   swiftgen
   ```

6. **Build and run**
   - Select target device/simulator
   - Press `Cmd + R` to build and run

### Configuration

1. **Environment Configuration**
   - Update `Dev.xcconfig` and `Release.xcconfig` with your settings
   - Configure API endpoints and keys

2. **Ads / IAP Flags**
   - Flip `AppFlags.adsEnabled` / `AppFlags.iapTrialEnabled` (`Sources/Configuration/AppFlags.swift`) directly in code — no remote server to configure

3. **In-App Purchases**
   - Update subscription product IDs in `SubscriptionManager.swift` ad and `Subscription.swift`
   - Configure StoreKit configuration file

## 🛠️ Development Workflow

### Adding New Features

1. **Create Module Structure**
   ```
   Modules/NewFeature/
   ├── NewFeatureView.swift
   ├── NewFeatureViewModel.swift
   └── NewFeatureViewCoordinator.swift
   ```

2. **Implement MVVM-C Pattern**
   ```swift
   // View
   struct NewFeatureView: View {
       @ObservedObject var viewModel: ViewModel
       
       var body: some View {
           BaseView(viewModel: viewModel) {
               // UI implementation
           }
       }
   }
   
   // ViewModel
   extension NewFeatureView {
       class ViewModel: BaseViewModel {
           @Published var coordinator: Coordinator = Coordinator()
           @Published var isLoading: Bool = false
           
           // Business logic
       }
   }
   
   // Coordinator
   extension NewFeatureView {
       struct Coordinator: BaseCoordinator {
           enum Navigation: BaseNavigation {
               case nextScreen
           }
           
           enum Alert: BaseAlert {
               case error(String)
           }
       }
   }
   ```

3. **Add Navigation Routes**
   - Update root coordinator with new routes
   - Implement navigation logic

### Adding New Services

1. **Create Service Protocol**
   ```swift
   protocol NewServiceProtocol {
       func performOperation() -> AnyPublisher<Result, Error>
   }
   ```

2. **Implement Service**
   ```swift
   class NewService: NewServiceProtocol {
       // Implementation
   }
   ```

## 🔧 Services Documentation

### API Service
The `APIService` provides a robust networking layer built on Alamofire:

```swift
// Features:
- Authentication interceptor for automatic
- Network logging for debugging
- Request/response caching
- Timeout configuration
- Error handling

// Usage:
@Injected var apiService: APIService
apiService.login(loginRequest) { result in
    // Handle response
}
```

### Subscription Manager
Complete In-App Purchase implementation with SwiftyStoreKit:

```swift
// Features:
- Auto-renewable subscriptions
- Purchase validation
- Receipt verification
- Restore purchases
- Subscription status tracking

// Usage:
@ObservedObject var subscriptionManager = SubscriptionManager()
subscriptionManager.purchase(product: product)
```

### File Storage Manager
Local file management system:

```swift
// Features:
- Create/delete files and folders
- File type detection
- Data persistence
- Error handling

// Usage:
@Injected var fileManager: FileStorageManager
fileManager.createFile(from: data, type: .pdf, in: folder)
```

### Core Data Stack
Persistent data storage with repository pattern:

```swift
// Features:
- Repository pattern implementation
- Background context handling
- Migration support
- Error handling

// Usage:
@Injected var personRepository: PersonDBRepository
personRepository.save(person)
```

## 🛠️ Code Generation and Linting

### SwiftGen

The project uses SwiftGen for generating type-safe access to assets, colors, and localizations.

#### Configuration
- SwiftGen configuration is defined in `swiftgen.yml`
- Generated files are stored in `Sources/Generated/`
- Custom templates in `Templates/` directory

#### Usage
1. To generate code:
```bash
swiftgen
```

2. The generated code provides type-safe access to:
   - Images: `Asset.Image.image1`
   - Colors: `Asset.Color.blue`
   - Icons: `Asset.Icon.facebook`
   - Fonts: `FontFamily.Roboto.regular`

3. To update generated code:
```bash
swiftgen config run
```

### SwiftLint

The project uses SwiftLint to enforce Swift style and conventions.

#### Configuration
- SwiftLint rules are defined in `.swiftlint.yml`
- Excludes generated code and third-party libraries
- Custom rules for SwiftUI best practices

#### Usage
1. To run SwiftLint:
```bash
swiftlint
```

2. To autocorrect violations:
```bash
swiftlint autocorrect
```

3. Integration with Xcode:
   - Automatically runs on build
   - Shows warnings and errors inline
   - Configured in build phases

## 🧪 Testing Guidelines

### Unit Testing

1. **ViewModel Testing**
   ```swift
   func testViewModelLogic() {
       let mockContainer = DIContainer(appState: AppState())
       let viewModel = HomeView.ViewModel(container: mockContainer)
       // Test business logic
   }
   ```

2. **Service Testing**
   ```swift
   func testAPIService() {
       let mockAPIService = MockAPIService()
       // Test service interactions
   }
   ```

### Subscription Testing

#### ⏱ Auto-Renewable Subscription Renewal Times (iOS Sandbox)

When testing auto-renewable subscriptions in the **iOS Sandbox environment**, Apple accelerates the renewal cycle:

| Real Duration    | Sandbox Renewal Time |
|------------------|----------------------|
| 1 week           | 3 minutes            |
| 1 month          | 5 minutes            |
| 2 months         | 10 minutes           |
| 3 months         | 15 minutes           |
| 6 months         | 30 minutes           |
| 1 year           | 1 hour               |

> 🔁 Each subscription will auto-renew up to **6 times** in the sandbox before stopping automatically.

#### 🧪 Testing Scenarios

**Testing Renewal and Expiration:**
1. Subscribe to a plan with a 1-month duration
2. Wait for sandbox renewal cycles (5 minutes each)
3. Verify subscription status changes
4. Test expiration after 6 renewals (~35 minutes)

**Testing Restore Purchases:**
1. Subscribe on one device
2. Install app on another device
3. Test restore functionality
4. Verify subscription status synchronization

## 📱 Best Practices

### Code Organization
- Follow MVVM-C pattern consistently
- Use dependency injection for loose coupling
- Implement proper error handling
- Write comprehensive unit tests

### Performance
- Use `@StateObject` for view model initialization
- Implement proper memory management with `CancelBag`
- Optimize image loading and caching
- Use lazy loading for large datasets

### Security
- Never commit API keys or secrets
- Use Keychain for sensitive data storage
- Implement certificate pinning for production
- Validate all user inputs

### UI/UX
- Follow Apple's Human Interface Guidelines
- Implement proper loading states
- Handle offline scenarios gracefully
- Provide meaningful error messages

## 🔍 Troubleshooting

### Common Issues

1. **SwiftGen not generating files**
   ```bash
   # Ensure SwiftGen is installed
   brew install swiftgen
   
   # Run generation
   swiftgen config run
   ```

2. **CocoaPods installation issues**
   ```bash
   # Clean and reinstall
   pod deintegrate
   pod clean
   pod install
   ```

3. **Build errors after dependency updates**
   ```bash
   # Clean build folder
   Product → Clean Build Folder (Cmd+Shift+K)
   ```

## 📚 Additional Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Combine Framework](https://developer.apple.com/documentation/combine)
- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [MVVM Pattern in SwiftUI](https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app)
- [In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow SwiftLint rules defined in `.swiftlint.yml`
- Use meaningful variable and function names
- Add documentation for public APIs
- Write unit tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ using SwiftUI and Clean Architecture principles**
