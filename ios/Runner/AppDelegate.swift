import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // BGTaskScheduler에 백그라운드 자동기록 작업 식별자 등록.
    // Info.plist의 BGTaskSchedulerPermittedIdentifiers와 일치해야 함.
    // frequency는 iOS BGAppRefresh의 minimumBackgroundFetchInterval 힌트.
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: "com.dottie.autorecord",
      frequency: NSNumber(value: 30 * 60)
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
