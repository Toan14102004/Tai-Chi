import SwiftUI

/// A navigator to use when the `FlowStack` is initialized with a `FlowPath` binding or no binding.
public typealias FlowPathNavigator = FlowNavigator<AnyHashable>

/// An object available via the environment that gives access to the current routes array.
@MainActor
public class FlowNavigator<Screen>: ObservableObject {
  let routesBinding: Binding<[Route<Screen>]>

  /// The current routes array.
  public var routes: [Route<Screen>] {
    get { routesBinding.wrappedValue }
    set { routesBinding.wrappedValue = newValue }
  }

  public init(_ routesBinding: Binding<[Route<Screen>]>) {
    self.routesBinding = routesBinding
  }
}

final class FlowNavigatorHolder {
    static let shared = FlowNavigatorHolder()
    var navigator: FlowPathNavigator?
    
    private init() {}
}

@propertyWrapper
@MainActor
struct Navigation {
    private var navigator: FlowPathNavigator {
        guard let navigator = FlowNavigatorHolder.shared.navigator else {
            fatalError("FlowPathNavigator chưa được khởi tạo. Đảm bảo bạn đã inject nó vào môi trường.")
        }
        return navigator
    }

    var wrappedValue: FlowPathNavigator {
        navigator
    }
}
