import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: Window?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = Window(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: "Main", bundle: .none).instantiateInitialViewController()
        window?.makeKeyAndVisible()

        window?.onShake = { [weak self] in
            let controller = UIAlertController(title: .none, message: "Choose book", preferredStyle: .actionSheet)
            let debugAction = UIAlertAction(title: "Sphera", style: .default, handler: { action in
                (self?.window?.rootViewController as? MainViewController)?.bookName.value = "small"
            })
            let prodAction = UIAlertAction(title: "Cooking for Geeks", style: .default, handler: { action in
                (self?.window?.rootViewController as? MainViewController)?.bookName.value = "big"
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)

            controller.addAction(debugAction)
            controller.addAction(prodAction)
            controller.addAction(cancelAction)

            if let popoverController = controller.popoverPresentationController {
                popoverController.sourceView = self?.window?.rootViewController?.view
            }

            self?.window?.rootViewController?.present(controller, animated: true, completion: .none)
        }

        return true
    }
}

