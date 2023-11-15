/*
 * Copyright 2020-2023. Huawei Technologies Co., Ltd. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:ui';

import 'package:agconnect_auth/agconnect_auth.dart';

import 'platform_auth.dart';

/// Information about the current user.
class AGCUser {
  bool? _isAnonymous;
  String? _uid;
  String? _email;
  String? _phone;
  String? _displayName;
  String? _photoUrl;
  AuthProviderType? _providerId;
  List<Map<String, String>>? _providerInfo;
  bool? _emailVerified;
  bool? _passwordSet;

  AGCUser.fromMap(Map map) {
    _updateUser(map);
  }

  void _updateUser(Map map) {
    _isAnonymous = map['isAnonymous'];
    _uid = map['uid'];
    _email = map['email'];
    _phone = map['phone'];
    _displayName = map['displayName'];
    _photoUrl = map['photoUrl'];
    _providerId = AuthProviderType.values[map['providerId']];
    _providerInfo = (map['providerInfo'] as List?)
        ?.map((e) => (e as Map)
            .map((key, value) => MapEntry(key.toString(), value.toString())))
        .toList(growable: false);
    _emailVerified = map['emailVerified'] == 1;
    _passwordSet = map['passwordSet'] == 1;
  }

  /// Checks whether a user is an anonymous user.
  bool? get isAnonymous {
    return _isAnonymous;
  }

  /// Obtains the user ID, which is generated by AppGallery Connect.
  String? get uid {
    return _uid;
  }

  /// Obtains the email address of a user.
  String? get email {
    return _email;
  }

  /// Obtains the mobile number of a user.
  String? get phone {
    return _phone;
  }

  /// Obtains the nickname of a user.
  String? get displayName {
    return _displayName;
  }

  /// Obtains the URL of a user's profile picture.
  String? get photoUrl {
    return _photoUrl;
  }

  /// Obtains the provider of the current user's account, that is, the name of the third-party authentication platform.
  AuthProviderType? get providerId {
    return _providerId;
  }

  /// Obtains all information about a user on the third-party authentication platform.
  List<Map<String, String>>? get providerInfo {
    return _providerInfo;
  }

  /// Obtains the email address verification flag.
  bool? get emailVerified {
    return _emailVerified;
  }

  /// Obtains the password setting flag.
  bool? get passwordSet {
    return _passwordSet;
  }

  /// Links a new authentication mode for the current user.
  Future<SignInResult> link(AGCAuthCredential credential) {
    return PlatformAuth.methodChannel.invokeMethod('link',
        <String, dynamic>{'credential': credential.toMap()}).then((value) {
      _updateUser(value);
      return SignInResult.fromMap(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Unlinks the current user from the linked authentication mode.
  Future<SignInResult> unlink(AuthProviderType provider) {
    return PlatformAuth.methodChannel.invokeMethod(
        'unlink', <String, dynamic>{'provider': provider.index}).then((value) {
      _updateUser(value);
      return SignInResult.fromMap(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Updates the profile information for the current user.
  Future<void> updateProfile(ProfileRequest profile) {
    return PlatformAuth.methodChannel.invokeMethod(
        'updateProfile', <String, dynamic>{
      'displayName': profile.displayName,
      'photoUrl': profile.photoUrl
    }).then((value) {
      _updateUser(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Updates the profile information for the current user.
  Future<void> updateEmail(String newEmail, String newVerifyCode,
      {Locale? locale}) {
    return PlatformAuth.methodChannel
        .invokeMethod('updateEmail', <String, dynamic>{
      'email': newEmail,
      'verifyCode': newVerifyCode,
      'localeLanguage': locale?.languageCode,
      'localeCountry': locale?.countryCode,
    }).then((value) {
      _updateUser(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Updates the mobile number of the current user.
  Future<void> updatePhone(
      String countryCode, String phoneNumber, String newVerifyCode,
      {Locale? locale}) {
    return PlatformAuth.methodChannel
        .invokeMethod('updatePhone', <String, dynamic>{
      'countryCode': countryCode,
      'phoneNumber': phoneNumber,
      'verifyCode': newVerifyCode,
      'localeLanguage': locale?.languageCode,
      'localeCountry': locale?.countryCode,
    }).then((value) {
      _updateUser(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Updates the current user's password.
  Future<void> updatePassword(
      String newPassword, String verifyCode, AuthProviderType provider) {
    return PlatformAuth.methodChannel.invokeMethod(
        'updatePassword', <String, dynamic>{
      'password': newPassword,
      'verifyCode': verifyCode,
      'provider': provider.index
    }).then((value) {
      _updateUser(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Obtains UserExtra of the current user.
  Future<AGCUserExtra> get userExtra {
    return PlatformAuth.methodChannel
        .invokeMethod('getUserExtra')
        .then((value) {
      _updateUser(value['user']);
      return AGCUserExtra.fromMap(value['userExtra']);
    }).catchError(PlatformAuth.handlePlatformException);
  }

  /// Obtains the access token of a user from AppGallery Connect.
  Future<TokenResult> getToken({bool forceRefresh = false}) {
    return PlatformAuth.methodChannel.invokeMethod('getToken',
        <String, dynamic>{'forceRefresh': forceRefresh}).then((value) {
      return TokenResult.fromMap(value);
    }).catchError(PlatformAuth.handlePlatformException);
  }
}