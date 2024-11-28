// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'PictureState.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pictureStateHash() => r'6c235a263b1fd605340c87745e87b0352577d5a0';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$PictureState
    extends BuildlessAutoDisposeNotifier<PictureContent> {
  late final String? fileId;

  PictureContent build(
    String? fileId,
  );
}

/// See also [PictureState].
@ProviderFor(PictureState)
const pictureStateProvider = PictureStateFamily();

/// See also [PictureState].
class PictureStateFamily extends Family<PictureContent> {
  /// See also [PictureState].
  const PictureStateFamily();

  /// See also [PictureState].
  PictureStateProvider call(
    String? fileId,
  ) {
    return PictureStateProvider(
      fileId,
    );
  }

  @override
  PictureStateProvider getProviderOverride(
    covariant PictureStateProvider provider,
  ) {
    return call(
      provider.fileId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'pictureStateProvider';
}

/// See also [PictureState].
class PictureStateProvider
    extends AutoDisposeNotifierProviderImpl<PictureState, PictureContent> {
  /// See also [PictureState].
  PictureStateProvider(
    String? fileId,
  ) : this._internal(
          () => PictureState()..fileId = fileId,
          from: pictureStateProvider,
          name: r'pictureStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pictureStateHash,
          dependencies: PictureStateFamily._dependencies,
          allTransitiveDependencies:
              PictureStateFamily._allTransitiveDependencies,
          fileId: fileId,
        );

  PictureStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileId,
  }) : super.internal();

  final String? fileId;

  @override
  PictureContent runNotifierBuild(
    covariant PictureState notifier,
  ) {
    return notifier.build(
      fileId,
    );
  }

  @override
  Override overrideWith(PictureState Function() create) {
    return ProviderOverride(
      origin: this,
      override: PictureStateProvider._internal(
        () => create()..fileId = fileId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fileId: fileId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PictureState, PictureContent>
      createElement() {
    return _PictureStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PictureStateProvider && other.fileId == fileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PictureStateRef on AutoDisposeNotifierProviderRef<PictureContent> {
  /// The parameter `fileId` of this provider.
  String? get fileId;
}

class _PictureStateProviderElement
    extends AutoDisposeNotifierProviderElement<PictureState, PictureContent>
    with PictureStateRef {
  _PictureStateProviderElement(super.provider);

  @override
  String? get fileId => (origin as PictureStateProvider).fileId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
