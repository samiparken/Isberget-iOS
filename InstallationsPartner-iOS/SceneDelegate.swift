
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    let defaults = UserDefaults.standard
    let jobManager = JobManager()

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        print("AppJustLaunched")
        self.defaults.set(true, forKey: K.UserDefaults.isAppJustLaunched)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        print("sceneDidDisconnect")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        print("sceneDidBecomeActive")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        print("APP - Background")
        locationManager.coreLocation.stopUpdatingLocation()
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        print("APP - Foreground")
        locationManager.coreLocation.startUpdatingLocation()
        
        //App Icon Badge Reset
        self.defaults.set(0, forKey: K.UserDefaults.applicationIconBadgeNumber)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        // Fetching all data when entering from background
        // + Try selective fetching data (not all data)
        /*
        let isJustLaunched = defaults.bool(forKey: K.UserDefaults.isAppJustLaunched)
        let token = defaults.string(forKey: K.UserDefaults.token) ?? ""
        if (isJustLaunched) {
            self.defaults.set(false, forKey: K.UserDefaults.isAppJustLaunched)
        } else if (token != ""){
            print("Reload all data")
            jobManager.getInitialData()
        }
        */
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}