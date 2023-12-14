import Foundation
import CarPlay

@objc
class CarSceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
  @objc
  static weak var sceneApplication: CPTemplateApplicationScene?
  
  func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
    AppDelegate.shared.initAppFromScene(connectionOptions: nil)
    
    RNCarPlay.connect(with: interfaceController, window: templateApplicationScene.carWindow);
    CarSceneDelegate.sceneApplication = templateApplicationScene;
  }

  func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
    CarSceneDelegate.sceneApplication = nil;
    RNCarPlay.disconnect()
  }
}
