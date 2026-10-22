import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

/// Runtime permissions that the app can request from the operating system.
enum AppPermissionKind { notifications, camera, photos }

class AppPermissionDefinition {
  const AppPermissionDefinition({required this.kind, required this.permission});

  final AppPermissionKind kind;
  final Permission permission;
}

class AppPermissionState {
  const AppPermissionState({required this.kind, required this.status});

  final AppPermissionKind kind;
  final PermissionStatus status;

  bool get isGranted =>
      status.isGranted || status.isLimited || status.isProvisional;

  bool get needsSystemSettings =>
      status.isPermanentlyDenied || status.isRestricted;
}

class AppPermissionsSnapshot {
  const AppPermissionsSnapshot({required this.permissions});

  final List<AppPermissionState> permissions;

  bool get isSupported => permissions.isNotEmpty;

  int get grantedCount => permissions.where((p) => p.isGranted).length;

  int get totalCount => permissions.length;
}

final appPermissionsServiceProvider = Provider<AppPermissionsService>(
  (ref) => const AppPermissionsService(),
);

/// Small wrapper around `permission_handler` so the permissions screen can be
/// driven by a fake in widget tests.
class AppPermissionsService {
  const AppPermissionsService();

  bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// Permissions actually requested by the app on the current platform.
  ///
  /// - Android: notifications (JPush) and camera (photo capture).
  /// - iOS: camera and photo library (image picker / saving images).
  ///
  /// Gallery picking and saving on modern Android versions goes through the
  /// system picker / MediaStore, so no runtime permission is required there.
  List<AppPermissionDefinition> get definitions {
    if (kIsWeb) return const [];

    if (Platform.isAndroid) {
      return const [
        AppPermissionDefinition(
          kind: AppPermissionKind.notifications,
          permission: Permission.notification,
        ),
        AppPermissionDefinition(
          kind: AppPermissionKind.camera,
          permission: Permission.camera,
        ),
      ];
    }

    if (Platform.isIOS) {
      return const [
        AppPermissionDefinition(
          kind: AppPermissionKind.camera,
          permission: Permission.camera,
        ),
        AppPermissionDefinition(
          kind: AppPermissionKind.photos,
          permission: Permission.photos,
        ),
      ];
    }

    return const [];
  }

  Future<AppPermissionsSnapshot> load() async {
    final states = await Future.wait(
      definitions.map((definition) async {
        PermissionStatus status;
        try {
          status = await definition.permission.status;
        } catch (error) {
          debugPrint(
            'AppPermissionsService: failed to read '
            '${definition.permission}: $error',
          );
          status = PermissionStatus.denied;
        }
        return AppPermissionState(kind: definition.kind, status: status);
      }),
    );

    return AppPermissionsSnapshot(permissions: states);
  }

  Future<PermissionStatus> request(AppPermissionKind kind) async {
    for (final definition in definitions) {
      if (definition.kind == kind) {
        return definition.permission.request();
      }
    }
    return PermissionStatus.restricted;
  }

  Future<bool> openSettings() => openAppSettings();
}

/// Requests camera access before opening the system camera picker.
///
/// Declaring `android.permission.CAMERA` in the manifest means Android requires
/// the permission to be granted before `ACTION_IMAGE_CAPTURE` is launched.
Future<bool> requestCameraPermission() async {
  try {
    final status = await Permission.camera.request();
    return status.isGranted || status.isLimited;
  } catch (error) {
    debugPrint('AppPermissionsService: camera request failed: $error');
    return false;
  }
}
