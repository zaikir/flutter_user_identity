import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_user_identity_method_channel.dart';

abstract class FlutterUserIdentityPlatform extends PlatformInterface {
  /// Constructs a FlutterUserIdentityPlatform.
  FlutterUserIdentityPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterUserIdentityPlatform _instance = MethodChannelFlutterUserIdentity();

  /// The default instance of [FlutterUserIdentityPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterUserIdentity].
  static FlutterUserIdentityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterUserIdentityPlatform] when
  /// they register themselves.
  static set instance(FlutterUserIdentityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getUserIdentity() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
