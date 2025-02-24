import Foundation
import DescopeKit
import UIKit

// MARK: - Services
@MainActor
final class Services {
    static let shared = Services()
    
    let auth: AuthService
    let artistApi: ArtistApi
    
    private init() {
        auth = AuthService.shared
        artistApi = ArtistApi.shared
    }
}

// MARK: - AuthService
@MainActor
final class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    
    static let shared = AuthService()
    private let projectId = HCEnvironment.descopeProjectId
    
    private init() {
        Descope.setup(projectId: projectId) { config in
            config.baseURL = HCEnvironment.authBaseURL
        }
        
        Task {
            isAuthenticated = await checkAuthentication()
        }
    }
    
    private func checkAuthentication() async -> Bool {
        return Descope.sessionManager.session != nil
    }
    
    func getToken() async -> String? {
        return Descope.sessionManager.session?.sessionToken.jwt
    }
    
    func startAuthFlow() {
        Task { @MainActor in
            let flowUrl = "\(HCEnvironment.authBaseURL)/login/\(projectId)?flow=sign-in-v2"
            let flow = DescopeFlow(url: flowUrl)
            let flowVC = DescopeFlowViewController()
            flowVC.delegate = self
            flowVC.start(flow: flow)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                rootVC.present(flowVC, animated: true)
            }
        }
    }
    
    func logout() async {
        await Descope.sessionManager.clearSession()
        isAuthenticated = false
    }
}

// MARK: - AuthService Delegate
extension AuthService: DescopeFlowViewControllerDelegate {
    nonisolated func flowViewControllerDidFinish(_ controller: DescopeFlowViewController, response: AuthenticationResponse) {
        Task { @MainActor in
            let session = DescopeSession(from: response)
            Descope.sessionManager.manageSession(session)
            isAuthenticated = true
            controller.dismiss(animated: true)
        }
    }
    
    nonisolated func flowViewControllerDidFail(_ controller: DescopeFlowViewController, error: DescopeError) {
        Task { @MainActor in
            print("Auth Error:", error)
            controller.dismiss(animated: true)
        }
    }
    
    // Required delegate methods
    nonisolated func flowViewControllerDidUpdateState(_ controller: DescopeFlowViewController, to: DescopeFlowState, from: DescopeFlowState) {}
    nonisolated func flowViewControllerDidBecomeReady(_ controller: DescopeFlowViewController) {}
    nonisolated func flowViewControllerDidCancel(_ controller: DescopeFlowViewController) {
        Task { @MainActor in
            controller.dismiss(animated: true)
        }
    }
    nonisolated func flowViewControllerShouldShowURL(_ controller: DescopeFlowViewController, url: URL, external: Bool) -> Bool { true }
}
