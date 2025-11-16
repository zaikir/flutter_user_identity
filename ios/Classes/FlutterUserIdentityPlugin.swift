import Flutter
import UIKit
import CloudKit
import Foundation
import Security

public class FlutterUserIdentityPlugin: NSObject, FlutterPlugin {
  private static let keychainService = Bundle.main.bundleIdentifier ?? "flutter_user_identity"
  private static let keychainKey = "user_identity_id"
  
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
    // First, check if we have a cached ID in Keychain
    if let cachedId = retrieveFromKeychain() {
      result(cachedId)
      return
    }
    
    // If not cached, fetch from CloudKit
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
        // Store in Keychain for future use
        self.storeInKeychain(recordName)
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
  
  private func storeInKeychain(_ value: String) {
    let data = value.data(using: .utf8)!
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.keychainService,
      kSecAttrAccount as String: Self.keychainKey,
      kSecValueData as String: data,
      kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    
    // Delete existing entry if it exists
    SecItemDelete(query as CFDictionary)
    
    // Add new entry
    SecItemAdd(query as CFDictionary, nil)
  }
  
  private func retrieveFromKeychain() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: Self.keychainService,
      kSecAttrAccount as String: Self.keychainKey,
      kSecReturnData as String: true
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess, let data = result as? Data else {
      return nil
    }
    
    return String(data: data, encoding: .utf8)
  }
}
