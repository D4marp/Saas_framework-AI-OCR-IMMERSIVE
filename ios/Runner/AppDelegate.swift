import Flutter
import UIKit
import ARKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    
    GeneratedPluginRegistrant.register(with: self)
    
    // Setup AR channel untuk iOS
    ARKitPlatformChannelSetup.setupARChannel(with: controller)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
