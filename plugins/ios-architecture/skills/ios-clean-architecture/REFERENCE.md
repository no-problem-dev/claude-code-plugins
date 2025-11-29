# iOS Clean Architecture - 詳細リファレンス

## 1. 各レイヤーの実装パターン

### Domain層

**責務**: ビジネスエンティティ・値オブジェクトの定義（UI非依存）

**ディレクトリ構成**:
```
Domain/Sources/Domain/
├── Models/           # エンティティ
├── Enums/            # 列挙型
├── Units/            # 単位系
├── Extensions/       # 標準型の拡張
├── Errors/           # ドメインエラー
└── Mocks/            # テスト用モックデータ
```

**実装例**:
```swift
// ✅ 正しい: 純粋なSwift型（Sendable準拠）
public struct User: Sendable, Hashable {
    public let id: String
    public let name: String
    public let createdAt: Date
}

// ✅ 正しい: enum による型安全な状態表現
public enum ActivityType: Sendable {
    case strength(StrengthData)
    case cardio(CardioData)
}

// ❌ 間違い: UIKit/SwiftUI依存
import SwiftUI  // Domain層では禁止
public struct UserView: View { ... }
```

### State層

**責務**: @Observable による状態管理

**パターン**:
```swift
import Foundation
import Domain
import Observation

@MainActor
@Observable
public final class UserState {
    // 状態（private(set)で外部からの直接変更を防止）
    public private(set) var user: User?
    public private(set) var isLoading: Bool = false
    public private(set) var error: String?

    public init() {}

    // Mutations（状態変更メソッド）
    public func setUser(_ user: User?) {
        self.user = user
    }

    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }

    public func setError(_ error: String?) {
        self.error = error
    }

    // Computed Properties（導出プロパティ）
    public var isLoggedIn: Bool {
        user != nil
    }
}
```

### Services層

**責務**: 再利用可能なアプリケーションサービス（外部SDK連携等）

**設計原則**:
- **Domainのみに依存**: Repositoryへの依存は禁止（独立性を保つ）
- **再利用可能**: 複数のUseCaseから利用される共通機能を提供
- **Protocol駆動**: テスタビリティのためProtocolを定義

**ディレクトリ構成**:
```
Services/Sources/Services/
├── HealthKit/        # ヘルスデータ連携
├── Location/         # 位置情報
├── Notification/     # プッシュ通知
├── Analytics/        # 分析サービス
└── Mocks/            # テスト用モック
```

**パターン**:
```swift
import Foundation
import Domain

// Protocol定義（UseCaseから利用）
public protocol HealthService: Sendable {
    func requestAuthorization() async throws
    func fetchWorkouts(from: Date, to: Date) async throws -> [ExternalWorkout]
}

// 実装（外部フレームワーク依存）
public final class HealthKitService: HealthService {
    public init() {}

    public func requestAuthorization() async throws {
        // HealthKit authorization
    }

    public func fetchWorkouts(from: Date, to: Date) async throws -> [ExternalWorkout] {
        // HealthKit query
        return []
    }
}

// ❌ 禁止パターン: Repositoryへの依存
public final class BadService {
    // private let repository: SomeRepository  // ❌ 禁止
}
```

**注意**: Services層はDomainのみに依存。Repository層への依存は禁止（UseCaseで統合する）。

### UseCases層

**責務**: ビジネスロジックのProtocol定義と実装

**依存**: Domain, Repository, Services

**パターン**:
```swift
import Foundation
import Domain
import Repository
import Services

// Protocol定義（テスタビリティのため）
public protocol WorkoutUseCase: Sendable {
    func syncWorkouts() async -> UseCaseResult<[Workout]>
}

// 結果型
public enum UseCaseResult<T: Sendable>: Sendable {
    case success(T)
    case failure(Error)
}

// 実装: Repository + Services を統合
public final class WorkoutUseCaseImpl: WorkoutUseCase {
    private let repository: WorkoutRepository
    private let healthService: HealthService  // Services層

    public init(
        repository: WorkoutRepository,
        healthService: HealthService
    ) {
        self.repository = repository
        self.healthService = healthService
    }

    public func syncWorkouts() async -> UseCaseResult<[Workout]> {
        do {
            // 1. Services層から外部データ取得
            let externalWorkouts = try await healthService.fetchWorkouts(
                from: Date().addingTimeInterval(-86400 * 7),
                to: Date()
            )

            // 2. Repository層でAPIに保存
            let workouts = try await repository.syncWorkouts(externalWorkouts)

            return .success(workouts)
        } catch {
            return .failure(error)
        }
    }
}
```

**ポイント**: UseCaseでServicesとRepositoryを統合。Servicesは直接Repositoryに依存しない。

### Repository層

**責務**: API通信・データ永続化

**APIClient使用例**:
```swift
import Foundation
import Domain
import APIClient

public final class UserRepository: Sendable {
    private let apiClient: APIClientImpl

    public init(apiClient: APIClientImpl) {
        self.apiClient = apiClient
    }

    public func fetchUser(id: String) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/api/users/\(id)",
            method: .get
        )
        return try await apiClient.request(endpoint)
    }

    public func updateUser(_ user: User) async throws -> User {
        let endpoint = APIEndpoint(
            path: "/api/users/\(user.id)",
            method: .put,
            body: user
        )
        return try await apiClient.request(endpoint)
    }
}
```

### Presentation層

**責務**: SwiftUI View・UIコンポーネント

## 2. no problem製SPMの使用例

### DesignSystem

**テーマ適用**:
```swift
import SwiftUI
import DesignSystem

// カスタムテーマ定義
public struct AppTheme: Theme {
    public let id = "app-theme"
    public let name = "App Theme"
    public let category: ThemeCategory = .custom

    public func colorPalette(for mode: ThemeMode) -> any ColorPalette {
        switch mode {
        case .light, .system: return AppLightPalette()
        case .dark: return AppDarkPalette()
        }
    }
}

// アプリルートでの適用
@main
struct MyApp: App {
    @State private var themeProvider = ThemeProvider(theme: AppTheme())

    var body: some Scene {
        WindowGroup {
            ContentView()
                .theme(themeProvider)
        }
    }
}

// View内でのトークン使用
struct MyView: View {
    @Environment(\.colorPalette) var colors
    @Environment(\.spacingScale) var spacing

    var body: some View {
        VStack(spacing: spacing.md) {
            Text("Title")
                .foregroundStyle(colors.primary)
        }
        .padding(spacing.lg)
        .background(colors.surface)
    }
}
```

### UIRouting

**タブナビゲーション**:
```swift
import SwiftUI
import UIRouting

// タブ定義
enum AppTab: Tabbable {
    case home, search, profile

    var title: String {
        switch self {
        case .home: "Home"
        case .search: "Search"
        case .profile: "Profile"
        }
    }

    var icon: String {
        switch self {
        case .home: "house"
        case .search: "magnifyingglass"
        case .profile: "person"
        }
    }

    @ViewBuilder
    var body: some View {
        switch self {
        case .home: HomeView()
        case .search: SearchView()
        case .profile: ProfileView()
        }
    }
}

// 使用
struct MainTabView: View {
    @State private var tabPresenter = TabPresenter(initialTab: AppTab.home)

    var body: some View {
        TabRouting(tabPresenter: tabPresenter, tabs: AppTab.allCases)
    }
}
```

**Push遷移**:
```swift
// ルート定義
enum AppRoute: Routable {
    case detail(id: String)
    case settings

    @ViewBuilder
    var body: some View {
        switch self {
        case .detail(let id):
            DetailView(id: id)
        case .settings:
            SettingsView()
        }
    }
}

// 使用
struct ListView: View {
    @Environment(\.router) var router: Router<AppRoute>

    var body: some View {
        Button("詳細を見る") {
            router.navigate(to: .detail(id: "123"))
        }
    }
}
```

**シート表示**:
```swift
enum AppSheet: Sheetable {
    case create
    case edit(id: String)

    @ViewBuilder
    var body: some View {
        switch self {
        case .create:
            CreateView()
        case .edit(let id):
            EditView(id: id)
        }
    }
}

struct ParentView: View {
    @State private var sheetPresenter = SheetPresenter<AppSheet>()

    var body: some View {
        Button("新規作成") {
            sheetPresenter.present(.create)
        }
        .sheet(sheetPresenter)
    }
}
```

### Authentication

**認証状態管理**:
```swift
import SwiftUI
import Authentication

struct RootView: View {
    var body: some View {
        AuthenticatedRootView(
            checking: { LoadingView() },
            unauthenticated: { LoginView() },
            firebaseAuthenticatedOnly: { InitializingView() },
            authenticated: { MainTabView() }
        )
    }
}

// ログインボタン
struct LoginView: View {
    var body: some View {
        VStack(spacing: 16) {
            GoogleSignInButton()
            AppleSignInButton()
        }
    }
}

// サインアウト
struct ProfileView: View {
    @Environment(\.authenticationUseCase) var auth

    var body: some View {
        Button("ログアウト") {
            Task { try await auth.signOut() }
        }
    }
}
```

### APIClient

**API通信**:
```swift
import APIClient

// クライアント初期化
let apiClient = APIClientImpl(
    baseURL: URL(string: "https://api.example.com")!,
    tokenProvider: FirebaseTokenProvider()
)

// GETリクエスト
struct UsersResponse: Codable {
    let users: [User]
}

let endpoint = APIEndpoint(
    path: "/api/users",
    method: .get,
    queryItems: [URLQueryItem(name: "limit", value: "10")]
)
let response: UsersResponse = try await apiClient.request(endpoint)

// POSTリクエスト
let createEndpoint = APIEndpoint(
    path: "/api/users",
    method: .post,
    body: CreateUserRequest(name: "John")
)
let newUser: User = try await apiClient.request(createEndpoint)
```

## 3. ファイル配置規則

### 新機能追加時のチェックリスト

1. **モデル追加** → `Domain/Sources/Domain/Models/`
2. **状態追加** → `State/Sources/State/`
3. **UseCase追加** → `UseCases/Sources/UseCases/`
4. **API通信追加** → `Repository/Sources/Repository/`
5. **画面追加** → `Presentation/Sources/Presentation/Views/`
6. **コンポーネント追加** → `Presentation/Sources/Presentation/Components/`
7. **ルート追加** → `Presentation/Sources/Presentation/Routing/`

### Package.swift更新が必要なケース

- 新しい外部依存の追加
- ターゲット間の新しい依存関係
- リソースファイル（画像、JSON等）の追加

## 4. よくある設計違反と修正

| 違反パターン | 問題点 | 修正方法 |
|------------|-------|---------|
| DomainでSwiftUI import | UI依存がコアに侵入 | Presentationに移動 |
| UseCaseでStateを直接変更 | 責務違反 | Viewから呼び出し後にState更新 |
| Repositoryで計算ロジック | ビジネスロジックの分散 | UseCaseに移動 |
| 複数レイヤーで同じモデル定義 | SSOT違反 | Domainに統一 |
| ViewでAPI直接呼び出し | レイヤー違反 | UseCase経由に変更 |

## 5. テスト戦略

### UseCaseのテスト

```swift
// Mock Repository
final class MockUserRepository: UserRepository {
    var fetchUserResult: Result<User, Error> = .success(User.mock)

    func fetchUser(id: String) async throws -> User {
        try fetchUserResult.get()
    }
}

// テスト
@Test func testGetUser() async {
    let mockRepo = MockUserRepository()
    let useCase = UserUseCaseImpl(repository: mockRepo)

    let result = await useCase.getUser(id: "123")

    guard case .success(let user) = result else {
        Issue.record("Expected success")
        return
    }
    #expect(user.id == "123")
}
```

### Stateのテスト

```swift
@Test @MainActor func testSetUser() {
    let state = UserState()

    state.setUser(User.mock)

    #expect(state.user != nil)
    #expect(state.isLoggedIn == true)
}
```

---

プロジェクト固有の設計原則は `/CLAUDE.md` および `docs/` を参照。
