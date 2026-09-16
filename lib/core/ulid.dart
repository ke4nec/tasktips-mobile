/// ULID 生成（Crockford base32，26 字符）。
library;

import 'dart:math';

const _alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

String newUlid() {
  final rnd = Random.secure();
  final ts = DateTime.now().millisecondsSinceEpoch;
  var s = '';
  var t = ts;
  for (var i = 9; i >= 0; i--) {
    s = _alphabet[t % 32] + s;
    t ~/= 32;
  }
  for (var i = 0; i < 16; i++) {
    s += _alphabet[rnd.nextInt(32)];
  }
  return s;
}
