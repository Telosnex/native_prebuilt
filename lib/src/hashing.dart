import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

final _sha256Hex = RegExp(r'^[0-9a-f]{64}$');

/// Whether [value] is a lowercase hex SHA-256 digest.
bool isSha256Hex(String value) => _sha256Hex.hasMatch(value);

/// The lowercase hex SHA-256 of the bytes of [file].
Future<String> sha256OfFile(File file) async =>
    (await sha256.bind(file.openRead()).first).toString();

/// The lowercase hex SHA-256 of [bytes].
String sha256OfBytes(List<int> bytes) => sha256.convert(bytes).toString();

/// The lowercase hex SHA-256 of the UTF-8 bytes of [text].
String sha256OfString(String text) => sha256OfBytes(utf8.encode(text));
