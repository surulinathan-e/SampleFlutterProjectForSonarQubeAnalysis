import 'dart:convert';

class AppConfig {
  final String? id;
  final String? aboutUrl;
  final String? appLatestVersion;
  final String? helpUrl;
  final String? privacyUrl;
  final String? termsUrl;
  final String? androidAppStoreUrl;
  final String? iOSAppStoreUrl;
  final bool? isActive;

  AppConfig(
    this.id,
    this.aboutUrl,
    this.appLatestVersion,
    this.helpUrl,
    this.privacyUrl,
    this.termsUrl,
    this.androidAppStoreUrl,
    this.iOSAppStoreUrl,
    this.isActive,
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'aboutUrl': aboutUrl,
      'appLatestVersion': appLatestVersion,
      'helpUrl': helpUrl,
      'privacyUrl': privacyUrl,
      'termsUrl': termsUrl,
      'AndroidAppStoreUrl': androidAppStoreUrl,
      'IOSAppStoreUrl': iOSAppStoreUrl,
      'isActive': isActive,
    };
  }

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      map['id'] == null ? null : map['id'] as String,
      map['aboutUrl'] == null ? null : map['aboutUrl'] as String,
      map['appLatestVersion'] == null
          ? null
          : map['appLatestVersion'] as String,
      map['helpUrl'] == null ? null : map['helpUrl'] as String,
      map['privacyUrl'] == null ? null : map['privacyUrl'] as String,
      map['termsUrl'] == null ? null : map['termsUrl'] as String,
      map['AndroidAppStoreUrl'] == null
          ? null
          : map['AndroidAppStoreUrl'] as String,
      map['IOSAppStoreUrl'] == null ? null : map['IOSAppStoreUrl'] as String,
      map['isActive'] == null ? false : map['isActive'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppConfig.fromJson(String source) =>
      AppConfig.fromMap(json.decode(source) as Map<String, dynamic>);
}
