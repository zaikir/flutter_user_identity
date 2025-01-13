import 'flutter_user_identity_platform_interface.dart';

class FlutterUserIdentity {
  Future<String?> getUserIdentity() {
    return FlutterUserIdentityPlatform.instance.getUserIdentity();
  }
}
