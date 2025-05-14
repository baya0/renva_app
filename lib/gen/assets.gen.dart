/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsIconsGen {
  const $AssetsIconsGen();

  /// Directory path: assets/icons/arrows
  $AssetsIconsArrowsGen get arrows => const $AssetsIconsArrowsGen();

  /// Directory path: assets/icons/document
  $AssetsIconsDocumentGen get document => const $AssetsIconsDocumentGen();

  /// Directory path: assets/icons/emojis
  $AssetsIconsEmojisGen get emojis => const $AssetsIconsEmojisGen();

  /// Directory path: assets/icons/essentials
  $AssetsIconsEssentialsGen get essentials => const $AssetsIconsEssentialsGen();

  /// Directory path: assets/icons/messages
  $AssetsIconsMessagesGen get messages => const $AssetsIconsMessagesGen();
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// Directory path: assets/images/logo
  $AssetsImagesLogoGen get logo => const $AssetsImagesLogoGen();
}

class $AssetsTranslationsGen {
  const $AssetsTranslationsGen();

  /// File path: assets/translations/ar.json
  String get ar => 'assets/translations/ar.json';

  /// File path: assets/translations/en.json
  String get en => 'assets/translations/en.json';

  /// List of all assets
  List<String> get values => [ar, en];
}

class $AssetsIconsArrowsGen {
  const $AssetsIconsArrowsGen();

  /// File path: assets/icons/arrows/left_circle.svg
  SvgGenImage get leftCircle =>
      const SvgGenImage('assets/icons/arrows/left_circle.svg');

  /// List of all assets
  List<SvgGenImage> get values => [leftCircle];
}

class $AssetsIconsDocumentGen {
  const $AssetsIconsDocumentGen();

  /// File path: assets/icons/document/check.svg
  SvgGenImage get check => const SvgGenImage('assets/icons/document/check.svg');

  /// File path: assets/icons/document/keyhole.svg
  SvgGenImage get keyhole =>
      const SvgGenImage('assets/icons/document/keyhole.svg');

  /// File path: assets/icons/document/shield.svg
  SvgGenImage get shield =>
      const SvgGenImage('assets/icons/document/shield.svg');

  /// List of all assets
  List<SvgGenImage> get values => [check, keyhole, shield];
}

class $AssetsIconsEmojisGen {
  const $AssetsIconsEmojisGen();

  /// File path: assets/icons/emojis/very_happy_face.svg
  SvgGenImage get veryHappyFace =>
      const SvgGenImage('assets/icons/emojis/very_happy_face.svg');

  /// List of all assets
  List<SvgGenImage> get values => [veryHappyFace];
}

class $AssetsIconsEssentialsGen {
  const $AssetsIconsEssentialsGen();

  /// File path: assets/icons/essentials/circle_user.svg
  SvgGenImage get circleUser =>
      const SvgGenImage('assets/icons/essentials/circle_user.svg');

  /// File path: assets/icons/essentials/eye.svg
  SvgGenImage get eye => const SvgGenImage('assets/icons/essentials/eye.svg');

  /// File path: assets/icons/essentials/eye_off.svg
  SvgGenImage get eyeOff =>
      const SvgGenImage('assets/icons/essentials/eye_off.svg');

  /// File path: assets/icons/essentials/gender.svg
  SvgGenImage get gender =>
      const SvgGenImage('assets/icons/essentials/gender.svg');

  /// File path: assets/icons/essentials/photo_camera.svg
  SvgGenImage get photoCamera =>
      const SvgGenImage('assets/icons/essentials/photo_camera.svg');

  /// List of all assets
  List<SvgGenImage> get values => [
    circleUser,
    eye,
    eyeOff,
    gender,
    photoCamera,
  ];
}

class $AssetsIconsMessagesGen {
  const $AssetsIconsMessagesGen();

  /// File path: assets/icons/messages/opened_mail.svg
  SvgGenImage get openedMail =>
      const SvgGenImage('assets/icons/messages/opened_mail.svg');

  /// File path: assets/icons/messages/phone_ring2.svg
  SvgGenImage get phoneRing2 =>
      const SvgGenImage('assets/icons/messages/phone_ring2.svg');

  /// List of all assets
  List<SvgGenImage> get values => [openedMail, phoneRing2];
}

class $AssetsImagesLogoGen {
  const $AssetsImagesLogoGen();

  /// File path: assets/images/logo/logo.svg
  SvgGenImage get logo => const SvgGenImage('assets/images/logo/logo.svg');

  /// File path: assets/images/logo/renva.svg
  SvgGenImage get renva => const SvgGenImage('assets/images/logo/renva.svg');

  /// File path: assets/images/logo/splash_light.svg
  SvgGenImage get splashLight =>
      const SvgGenImage('assets/images/logo/splash_light.svg');

  /// List of all assets
  List<SvgGenImage> get values => [logo, renva, splashLight];
}

class Assets {
  const Assets._();

  static const $AssetsIconsGen icons = $AssetsIconsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
  static const $AssetsTranslationsGen translations = $AssetsTranslationsGen();
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
