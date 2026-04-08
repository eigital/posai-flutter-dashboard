import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:eo_dashboard_flutter/constants/cookie_keys.dart';
import 'package:eo_dashboard_flutter/constants/storage_keys.dart';

/// Unwraps eatOS `{ success, response, message }` (`response` object or JSON string).
/// Mirrors [toPayload] in [eatos-live-dashboard/src/services/authService.ts].
Map<String, dynamic> toPayload(dynamic input) {
  if (input is! Map) {
    return {};
  }
  final body = Map<String, dynamic>.from(input);
  final inner = body['response'];
  if (inner != null && inner is Map) {
    return Map<String, dynamic>.from(inner);
  }
  if (inner is String && inner.trim().isNotEmpty) {
    try {
      final parsed = jsonDecode(inner);
      if (parsed is Map<String, dynamic>) {
        return parsed;
      }
    } catch (_) {
      /* fall through */
    }
  }
  return body;
}

String? coalesceStr(List<dynamic> values) {
  for (final v in values) {
    if (v != null && v.toString().trim().isNotEmpty) {
      return v.toString();
    }
  }
  return null;
}

List<Map<String, dynamic>> permissionList(Map<String, dynamic> payload) {
  final perms = payload['permissions'];
  if (perms is List && perms.isNotEmpty) {
    return perms.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  final role = payload['role'];
  if (role is Map) {
    final fromRole = role['permissions'];
    if (fromRole is List && fromRole.isNotEmpty) {
      return fromRole.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }
  return [];
}

({String code, String symbol})? parseCurrency(String value) {
  final parts = value.split('-').map((e) => e.trim()).toList();
  if (parts.length < 2) {
    return null;
  }
  final codePart = parts[0];
  final symbolPart = parts.sublist(1).join('-').trim();
  if (codePart.isEmpty || symbolPart.isEmpty) {
    return null;
  }
  return (code: codePart, symbol: symbolPart);
}

/// Mirrors [toSettingsArray] in authService.ts.
List<Map<String, dynamic>> toSettingsArray(dynamic input) {
  if (input is List) {
    return input.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  if (input is Map) {
    final o = Map<String, dynamic>.from(input);
    final response = o['response'];
    if (response is List) {
      return response.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (response is Map) {
      final responseMap = Map<String, dynamic>.from(response);
      if (isSingleSettingRecord(responseMap)) {
        return [responseMap];
      }
    }
    final data = o['data'];
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    final settings = o['settings'];
    if (settings is List) {
      return settings.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (isSingleSettingRecord(o)) {
      return [o];
    }
  }
  return [];
}

bool isSingleSettingRecord(Map<String, dynamic> o) {
  final hasName = o['settingName'] is String && (o['settingName'] as String).trim().isNotEmpty;
  final hasId = o['settingId'] is String && (o['settingId'] as String).trim().isNotEmpty;
  if (!hasName && !hasId) {
    return false;
  }
  return o.containsKey('settingValue') || o.containsKey('value');
}

/// Applies store settings (same keys as React localStorage + currency cookies).
Future<void> applyStoreSettings(SharedPreferences prefs, dynamic settingsInput) async {
  final settingsArray = toSettingsArray(settingsInput);
  const supportedKeys = <String>{
    storageKeyTimezone,
    storageKeyCurrencyRaw,
    storageKeyDateFormat,
    storageKeyStoreAddress,
    storageKeyStoreCity,
    storageKeyStoreState,
    storageKeyStoreCountry,
    storageKeyStoreZipcode,
    storageKeyTaxAlias,
    storageKeyClosingDay,
    storageKeyStartOfHour,
    storageKeyEndOfHour,
    storageKeyHtmlSupports,
  };

  for (final setting in settingsArray) {
    final key = (setting['settingName'] ?? setting['key'] ?? setting['name'] ?? '').toString();
    if (!supportedKeys.contains(key)) {
      continue;
    }
    final rawValue = setting['settingValue'] ?? setting['value'] ?? '';
    final value = rawValue.toString();
    await prefs.setString(key, value);

    if (key == storageKeyCurrencyRaw) {
      final parsed = parseCurrency(value);
      if (parsed != null) {
        await prefs.setString(storageKeyCurrencySymbol, parsed.symbol);
        await prefs.setString(cookieKeyCurrency, parsed.symbol);
        await prefs.setString(cookieKeyCurrencyCode, parsed.code);
      }
    }
  }
}
