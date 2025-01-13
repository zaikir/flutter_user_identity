import Flutter
import UIKit
import CloudKit
import Foundation

public class FlutterUserIdentityPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_user_identity", binaryMessenger: registrar.messenger())
    let instance = FlutterUserIdentityPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getUserIdentity":
      getUserIdentity(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func getUserIdentity(result: @escaping FlutterResult) {
    guard let ckIdentifier = Bundle.main.object(forInfoDictionaryKey: "CK_CONTAINER_IDENTIFIER") as? String else {
      result(
        FlutterError(
          code: "NO_CONTAINER_IDENTIFIER",
          message: "Missing CK_CONTAINER_IDENTIFIER in Info.plist",
          details: nil
        )
      )
      return
    }

    CKContainer(identifier: ckIdentifier).fetchUserRecordID { recordID, error in
      if let recordName = recordID?.recordName {
        result(recordName)
      } else if let ckerror = error as? CKError, ckerror.code == .notAuthenticated {
        result(
          FlutterError(
            code: "NO_ACCOUNT_ACCESS_ERROR",
            message: "No iCloud account is associated with the device, or access to the account is restricted.",
            details: nil
          )
        )
      } else if let error = error {
        result(
          FlutterError(
            code: "NS_ERROR",
            message: error.localizedDescription,
            details: nil
          )
        )
      } else {
        result(
          FlutterError(
            code: "UNKNOWN_ERROR",
            message: "An unknown error occurred.",
            details: nil
          )
        )
      }
    }
  }
}
