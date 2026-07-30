// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Notes`
  String get appName {
    return Intl.message('Notes', name: 'appName', desc: '', args: []);
  }

  /// `Application language`
  String get applicationLanguage {
    return Intl.message(
      'Application language',
      name: 'applicationLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Select application language`
  String get subtitleLanguage {
    return Intl.message(
      'Select application language',
      name: 'subtitleLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Select language`
  String get selectLanguage {
    return Intl.message(
      'Select language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Russian`
  String get russian {
    return Intl.message('Russian', name: 'russian', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `French`
  String get french {
    return Intl.message('French', name: 'french', desc: '', args: []);
  }

  /// `Deutsch`
  String get deutsch {
    return Intl.message('Deutsch', name: 'deutsch', desc: '', args: []);
  }

  /// `Italian`
  String get italian {
    return Intl.message('Italian', name: 'italian', desc: '', args: []);
  }

  /// `Portuguese`
  String get portuguese {
    return Intl.message('Portuguese', name: 'portuguese', desc: '', args: []);
  }

  /// `Spanish`
  String get spanish {
    return Intl.message('Spanish', name: 'spanish', desc: '', args: []);
  }

  /// `Chinese`
  String get chinese {
    return Intl.message('Chinese', name: 'chinese', desc: '', args: []);
  }

  /// `Korean`
  String get korean {
    return Intl.message('Korean', name: 'korean', desc: '', args: []);
  }

  /// `Japanese`
  String get japanese {
    return Intl.message('Japanese', name: 'japanese', desc: '', args: []);
  }

  /// `Select theme`
  String get selectTheme {
    return Intl.message(
      'Select theme',
      name: 'selectTheme',
      desc: '',
      args: [],
    );
  }

  /// `Default`
  String get system {
    return Intl.message('Default', name: 'system', desc: '', args: []);
  }

  /// `Light`
  String get light {
    return Intl.message('Light', name: 'light', desc: '', args: []);
  }

  /// `Dark`
  String get dark {
    return Intl.message('Dark', name: 'dark', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `ОК`
  String get ok {
    return Intl.message('ОК', name: 'ok', desc: '', args: []);
  }

  /// `Apply`
  String get apply {
    return Intl.message('Apply', name: 'apply', desc: '', args: []);
  }

  /// `Version`
  String get version {
    return Intl.message('Version', name: 'version', desc: '', args: []);
  }

  /// `Font size`
  String get fontSize {
    return Intl.message('Font size', name: 'fontSize', desc: '', args: []);
  }

  /// `Select font`
  String get selectFont {
    return Intl.message('Select font', name: 'selectFont', desc: '', args: []);
  }

  /// `Small`
  String get small {
    return Intl.message('Small', name: 'small', desc: '', args: []);
  }

  /// `Average`
  String get average {
    return Intl.message('Average', name: 'average', desc: '', args: []);
  }

  /// `Big`
  String get big {
    return Intl.message('Big', name: 'big', desc: '', args: []);
  }

  /// `Blue`
  String get blueColor {
    return Intl.message('Blue', name: 'blueColor', desc: '', args: []);
  }

  /// `Red`
  String get redColor {
    return Intl.message('Red', name: 'redColor', desc: '', args: []);
  }

  /// `Green`
  String get greenColor {
    return Intl.message('Green', name: 'greenColor', desc: '', args: []);
  }

  /// `Orange`
  String get orangeColor {
    return Intl.message('Orange', name: 'orangeColor', desc: '', args: []);
  }

  /// `Select color scheme`
  String get selectColorScheme {
    return Intl.message(
      'Select color scheme',
      name: 'selectColorScheme',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get lightNotify {
    return Intl.message('Light', name: 'lightNotify', desc: '', args: []);
  }

  /// `No Internet Connection`
  String get noInternetConnection {
    return Intl.message(
      'No Internet Connection',
      name: 'noInternetConnection',
      desc: '',
      args: [],
    );
  }

  /// `Please check your internet settings and try again.`
  String get checkInternetSettings {
    return Intl.message(
      'Please check your internet settings and try again.',
      name: 'checkInternetSettings',
      desc: '',
      args: [],
    );
  }

  /// `Load more`
  String get loadMore {
    return Intl.message('Load more', name: 'loadMore', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
