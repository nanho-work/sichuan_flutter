// lib/managers/image_manager.dart
import 'package:flutter/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// DialogType enum for different dialog background assets
enum DialogType { energy }

extension DialogTypePath on DialogType {
  String get assetPath {
    switch (this) {
      case DialogType.energy:
        return 'assets/images/dialogs/dialog_bg_energy.png';
    }
  }
}



/// ButtonType enum for different button assets
enum ButtonType { wood }

extension ButtonTypePath on ButtonType {
  String get assetPath {
    switch (this) {
      case ButtonType.wood:
        return 'assets/images/buttons/wood_button.png';
    }
  }
}

/// CurrencyType enum for different currency icons
enum CurrencyType { energy, gem, gold }

extension CurrencyTypePath on CurrencyType {
  String get assetPath {
    switch (this) {
      case CurrencyType.energy:
        return 'assets/images/item_carrot.png';
      case CurrencyType.gem:
        return 'assets/images/item_rubyberry.png';
      case CurrencyType.gold:
        return 'assets/images/item_acorn.png';
    }
  }
}

/// ImageManager
/// - 하이브리드 전략: 로컬 asset 우선, remote URL 있으면 캐시/로딩 시도, 실패 시 asset fallback.
/// - 반환 타입은 ImageProvider 또는 Widget (CachedNetworkImage 사용).
class ImageManager {
  ImageManager._();
  static final ImageManager instance = ImageManager._();

  // 로컬 매핑: itemId -> asset path
  // 필요한 기본 아이템들은 여기서 관리
  final Map<String, String> _localMap = {
    'char_default': 'assets/images/characters/char_default.png',
    'char_fox': 'assets/images/characters/char_fox.png',
  };

  /// 기본/custom 캐시 매니저 (옵션으로 설정)
  final BaseCacheManager _cacheManager = DefaultCacheManager();

  /// 특정 아이템의 ImageProvider를 반환.
  /// - remoteUrl 우선(있으면 캐시된 네트워크 이미지 사용, 실패 시 asset fallback)
  /// - remoteUrl 없으면 asset 사용
  ImageProvider getImageProvider({
    required String itemId,
    String? remoteUrl,
    double scale = 1.0,
  }) {
    // 만약 remoteUrl이 있고, CachedNetworkImageProvider를 쓸 수 있으면 먼저 시도.
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      // CachedNetworkImageProvider uses flutter_cache_manager internally.
      return CachedNetworkImageProvider(remoteUrl, cacheManager: _cacheManager, scale: scale);
    }

    // fallback to asset (if asset exists)
    final asset = _localMap[itemId];
    if (asset != null) {
      return AssetImage(asset, package: null);
    }

    // ultimate fallback: char_default asset
    return AssetImage(_localMap['char_default']!);
  }

  /// Widget 형태로 반환 (이미지 로딩 중 플레이스홀더/에러 핸들링 포함)
  Widget imageWidget({
    required String itemId,
    String? remoteUrl,
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    final assetPath = _localMap[itemId];
    placeholder ??= Image.asset(_localMap['char_default']!, fit: fit, width: width, height: height);

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: remoteUrl,
        cacheManager: _cacheManager,
        imageBuilder: (context, imageProvider) => Image(
          image: imageProvider,
          fit: fit,
          width: width,
          height: height,
        ),
        placeholder: (context, url) => placeholder!,
        errorWidget: (context, url, error) {
          // 네트워크 실패 시 local asset fallback or provided errorWidget
          if (assetPath != null) {
            return Image.asset(assetPath, fit: fit, width: width, height: height);
          }
          return errorWidget ?? placeholder!;
        },
      );
    }

    // no remote -> local asset or placeholder
    if (assetPath != null) {
      return Image.asset(assetPath, fit: fit, width: width, height: height);
    }

    return placeholder!;
  }

  /// 아이템ID -> 로컬 asset 경로 가져오기 (nullable)
  String? getLocalAssetPath(String itemId) => _localMap[itemId];

  /// 로컬 맵에 새로운 기본 매핑 추가(런타임에서 기본 asset을 등록하고 싶을 때)
  void registerLocalAsset(String itemId, String assetPath) {
    _localMap[itemId] = assetPath;
  }

  /// 미리 프리캐시(자주 쓰는 이미지를 앱 시작 시 캐시)
  /// - 로컬 asset은 precacheImage로 캐시 가능
  Future<void> precacheAssets(BuildContext context, {List<String>? itemIds}) async {
    final ids = itemIds ?? _localMap.keys.toList();
    for (final id in ids) {
      final path = _localMap[id];
      if (path != null) {
        try {
          await precacheImage(AssetImage(path), context);
        } catch (_) {
          // 무시
        }
      }
    }
  }

  /// remote URL을 미리 다운로드 해서 캐시에 저장 (네트워크 이미지를 미리 캐싱)
  Future<void> prefetchRemote(String url) async {
    if (url.isEmpty) return;
    try {
      await _cacheManager.downloadFile(url);
    } catch (_) {
      // 무시
    }
  }

  /// Returns a currency icon Image widget for the given CurrencyType.
  Image getCurrencyIcon(CurrencyType type, {double size = 20}) {
    return Image.asset(type.assetPath, width: size, height: size);
  }

  /// Returns a button Image widget for the given ButtonType.
  Image getButtonImage(ButtonType type, {double size = 40}) {
    return Image.asset(type.assetPath, width: size, height: size);
  }

  /// Returns a dialog background Image widget for the given DialogType.
  Image getDialogBackground(DialogType type, {BoxFit fit = BoxFit.cover}) {
    return Image.asset(type.assetPath, fit: fit);
  }
}