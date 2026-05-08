import 'package:flutter/material.dart';
import 'generated/l10n/l10n.dart';

String getAppName(BuildContext context) {
  return S.of(context).appName;
}

String appVersion = '1.0.2';
String appBuildNumber = '246';
