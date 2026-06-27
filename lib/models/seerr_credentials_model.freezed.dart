// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'seerr_credentials_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SeerrCredentialsModel {
  String get serverUrl;
  String get apiKey;
  String get sessionCookie;
  Map<String, String> get customHeaders;
  bool get enableQuickRequest;
  bool get enableKidsMode;
  int? get defaultRadarrServerId;
  int? get defaultRadarrProfileId;
  String? get defaultRadarrRootFolder;

  /// Create a copy of SeerrCredentialsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SeerrCredentialsModelCopyWith<SeerrCredentialsModel> get copyWith =>
      _$SeerrCredentialsModelCopyWithImpl<SeerrCredentialsModel>(
          this as SeerrCredentialsModel, _$identity);

  /// Serializes this SeerrCredentialsModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  String toString() {
    return 'SeerrCredentialsModel(serverUrl: $serverUrl, apiKey: $apiKey, sessionCookie: $sessionCookie, customHeaders: $customHeaders, enableQuickRequest: $enableQuickRequest, enableKidsMode: $enableKidsMode, defaultRadarrServerId: $defaultRadarrServerId, defaultRadarrProfileId: $defaultRadarrProfileId, defaultRadarrRootFolder: $defaultRadarrRootFolder)';
  }
}

/// @nodoc
abstract mixin class $SeerrCredentialsModelCopyWith<$Res> {
  factory $SeerrCredentialsModelCopyWith(SeerrCredentialsModel value,
          $Res Function(SeerrCredentialsModel) _then) =
      _$SeerrCredentialsModelCopyWithImpl;
  @useResult
  $Res call(
      {String serverUrl,
      String apiKey,
      String sessionCookie,
      Map<String, String> customHeaders,
      bool enableQuickRequest,
      bool enableKidsMode,
      int? defaultRadarrServerId,
      int? defaultRadarrProfileId,
      String? defaultRadarrRootFolder});
}

/// @nodoc
class _$SeerrCredentialsModelCopyWithImpl<$Res>
    implements $SeerrCredentialsModelCopyWith<$Res> {
  _$SeerrCredentialsModelCopyWithImpl(this._self, this._then);

  final SeerrCredentialsModel _self;
  final $Res Function(SeerrCredentialsModel) _then;

  /// Create a copy of SeerrCredentialsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? serverUrl = null,
    Object? apiKey = null,
    Object? sessionCookie = null,
    Object? customHeaders = null,
    Object? enableQuickRequest = null,
    Object? enableKidsMode = null,
    Object? defaultRadarrServerId = freezed,
    Object? defaultRadarrProfileId = freezed,
    Object? defaultRadarrRootFolder = freezed,
  }) {
    return _then(_self.copyWith(
      serverUrl: null == serverUrl
          ? _self.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      sessionCookie: null == sessionCookie
          ? _self.sessionCookie
          : sessionCookie // ignore: cast_nullable_to_non_nullable
              as String,
      customHeaders: null == customHeaders
          ? _self.customHeaders
          : customHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      enableQuickRequest: null == enableQuickRequest
          ? _self.enableQuickRequest
          : enableQuickRequest // ignore: cast_nullable_to_non_nullable
              as bool,
      enableKidsMode: null == enableKidsMode
          ? _self.enableKidsMode
          : enableKidsMode // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultRadarrServerId: freezed == defaultRadarrServerId
          ? _self.defaultRadarrServerId
          : defaultRadarrServerId // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultRadarrProfileId: freezed == defaultRadarrProfileId
          ? _self.defaultRadarrProfileId
          : defaultRadarrProfileId // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultRadarrRootFolder: freezed == defaultRadarrRootFolder
          ? _self.defaultRadarrRootFolder
          : defaultRadarrRootFolder // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [SeerrCredentialsModel].
extension SeerrCredentialsModelPatterns on SeerrCredentialsModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SeerrCredentialsModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SeerrCredentialsModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SeerrCredentialsModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SeerrCredentialsModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SeerrCredentialsModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SeerrCredentialsModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String serverUrl,
            String apiKey,
            String sessionCookie,
            Map<String, String> customHeaders,
            bool enableQuickRequest,
            bool enableKidsMode,
            int? defaultRadarrServerId,
            int? defaultRadarrProfileId,
            String? defaultRadarrRootFolder)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SeerrCredentialsModel() when $default != null:
        return $default(
            _that.serverUrl,
            _that.apiKey,
            _that.sessionCookie,
            _that.customHeaders,
            _that.enableQuickRequest,
            _that.enableKidsMode,
            _that.defaultRadarrServerId,
            _that.defaultRadarrProfileId,
            _that.defaultRadarrRootFolder);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String serverUrl,
            String apiKey,
            String sessionCookie,
            Map<String, String> customHeaders,
            bool enableQuickRequest,
            bool enableKidsMode,
            int? defaultRadarrServerId,
            int? defaultRadarrProfileId,
            String? defaultRadarrRootFolder)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SeerrCredentialsModel():
        return $default(
            _that.serverUrl,
            _that.apiKey,
            _that.sessionCookie,
            _that.customHeaders,
            _that.enableQuickRequest,
            _that.enableKidsMode,
            _that.defaultRadarrServerId,
            _that.defaultRadarrProfileId,
            _that.defaultRadarrRootFolder);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String serverUrl,
            String apiKey,
            String sessionCookie,
            Map<String, String> customHeaders,
            bool enableQuickRequest,
            bool enableKidsMode,
            int? defaultRadarrServerId,
            int? defaultRadarrProfileId,
            String? defaultRadarrRootFolder)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SeerrCredentialsModel() when $default != null:
        return $default(
            _that.serverUrl,
            _that.apiKey,
            _that.sessionCookie,
            _that.customHeaders,
            _that.enableQuickRequest,
            _that.enableKidsMode,
            _that.defaultRadarrServerId,
            _that.defaultRadarrProfileId,
            _that.defaultRadarrRootFolder);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _SeerrCredentialsModel extends SeerrCredentialsModel {
  const _SeerrCredentialsModel(
      {this.serverUrl = "",
      this.apiKey = "",
      this.sessionCookie = "",
      final Map<String, String> customHeaders = const {},
      this.enableQuickRequest = false,
      this.enableKidsMode = false,
      this.defaultRadarrServerId,
      this.defaultRadarrProfileId,
      this.defaultRadarrRootFolder})
      : _customHeaders = customHeaders,
        super._();
  factory _SeerrCredentialsModel.fromJson(Map<String, dynamic> json) =>
      _$SeerrCredentialsModelFromJson(json);

  @override
  @JsonKey()
  final String serverUrl;
  @override
  @JsonKey()
  final String apiKey;
  @override
  @JsonKey()
  final String sessionCookie;
  final Map<String, String> _customHeaders;
  @override
  @JsonKey()
  Map<String, String> get customHeaders {
    if (_customHeaders is EqualUnmodifiableMapView) return _customHeaders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customHeaders);
  }

  @override
  @JsonKey()
  final bool enableQuickRequest;
  @override
  @JsonKey()
  final bool enableKidsMode;
  @override
  final int? defaultRadarrServerId;
  @override
  final int? defaultRadarrProfileId;
  @override
  final String? defaultRadarrRootFolder;

  /// Create a copy of SeerrCredentialsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SeerrCredentialsModelCopyWith<_SeerrCredentialsModel> get copyWith =>
      __$SeerrCredentialsModelCopyWithImpl<_SeerrCredentialsModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SeerrCredentialsModelToJson(
      this,
    );
  }

  @override
  String toString() {
    return 'SeerrCredentialsModel(serverUrl: $serverUrl, apiKey: $apiKey, sessionCookie: $sessionCookie, customHeaders: $customHeaders, enableQuickRequest: $enableQuickRequest, enableKidsMode: $enableKidsMode, defaultRadarrServerId: $defaultRadarrServerId, defaultRadarrProfileId: $defaultRadarrProfileId, defaultRadarrRootFolder: $defaultRadarrRootFolder)';
  }
}

/// @nodoc
abstract mixin class _$SeerrCredentialsModelCopyWith<$Res>
    implements $SeerrCredentialsModelCopyWith<$Res> {
  factory _$SeerrCredentialsModelCopyWith(_SeerrCredentialsModel value,
          $Res Function(_SeerrCredentialsModel) _then) =
      __$SeerrCredentialsModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String serverUrl,
      String apiKey,
      String sessionCookie,
      Map<String, String> customHeaders,
      bool enableQuickRequest,
      bool enableKidsMode,
      int? defaultRadarrServerId,
      int? defaultRadarrProfileId,
      String? defaultRadarrRootFolder});
}

/// @nodoc
class __$SeerrCredentialsModelCopyWithImpl<$Res>
    implements _$SeerrCredentialsModelCopyWith<$Res> {
  __$SeerrCredentialsModelCopyWithImpl(this._self, this._then);

  final _SeerrCredentialsModel _self;
  final $Res Function(_SeerrCredentialsModel) _then;

  /// Create a copy of SeerrCredentialsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? serverUrl = null,
    Object? apiKey = null,
    Object? sessionCookie = null,
    Object? customHeaders = null,
    Object? enableQuickRequest = null,
    Object? enableKidsMode = null,
    Object? defaultRadarrServerId = freezed,
    Object? defaultRadarrProfileId = freezed,
    Object? defaultRadarrRootFolder = freezed,
  }) {
    return _then(_SeerrCredentialsModel(
      serverUrl: null == serverUrl
          ? _self.serverUrl
          : serverUrl // ignore: cast_nullable_to_non_nullable
              as String,
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      sessionCookie: null == sessionCookie
          ? _self.sessionCookie
          : sessionCookie // ignore: cast_nullable_to_non_nullable
              as String,
      customHeaders: null == customHeaders
          ? _self._customHeaders
          : customHeaders // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      enableQuickRequest: null == enableQuickRequest
          ? _self.enableQuickRequest
          : enableQuickRequest // ignore: cast_nullable_to_non_nullable
              as bool,
      enableKidsMode: null == enableKidsMode
          ? _self.enableKidsMode
          : enableKidsMode // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultRadarrServerId: freezed == defaultRadarrServerId
          ? _self.defaultRadarrServerId
          : defaultRadarrServerId // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultRadarrProfileId: freezed == defaultRadarrProfileId
          ? _self.defaultRadarrProfileId
          : defaultRadarrProfileId // ignore: cast_nullable_to_non_nullable
              as int?,
      defaultRadarrRootFolder: freezed == defaultRadarrRootFolder
          ? _self.defaultRadarrRootFolder
          : defaultRadarrRootFolder // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
