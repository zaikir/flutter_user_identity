import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_user_identity_platform_interface.dart';

/// An implementation of [FlutterUserIdentityPlatform] that uses method channels.
class MethodChannelFlutterUserIdentity extends FlutterUserIdentityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_user_identity');

  @override
  Future<String?> getUserIdentity() async {
    final String? userId = await methodChannel.invokeMethod('getUserIdentity');
    return userId;
  }
}
