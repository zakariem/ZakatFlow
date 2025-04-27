import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/zakat_providers.dart';

final zakatXoolahaViewModelProvider = Provider<ZakatXoolahaViewModel>(
  (ref) => ZakatXoolahaViewModel(ref),
);

class ZakatXoolahaViewModel {
  final Ref ref;
  ZakatXoolahaViewModel(this.ref);

  Map<String, String> calculateLivestockZakat() {
    double camelCount = double.tryParse(ref.read(camelValueProvider)) ?? 0;
    double cowCount = double.tryParse(ref.read(cowValueProvider)) ?? 0;
    double sheepCount = double.tryParse(ref.read(sheepValueProvider)) ?? 0;

    String camelZakat = _calculateCamelZakat(camelCount);
    String cowZakat = _calculateCowZakat(cowCount);
    String sheepZakat = _calculateSheepZakat(sheepCount);

    return {'camels': camelZakat, 'cows': cowZakat, 'sheep': sheepZakat};
  }

  String _calculateCamelZakat(double count) {
    if (count < 5) return 'Zakada lama rabo (ma jirto zakaa la bixinayo)';
    if (count >= 5 && count < 10) return '1 ido ama 1 ari';
    if (count >= 10 && count < 15) return '2 ido ama 2 ari';
    if (count >= 15 && count < 20) return '3 ido ama 3 ari';
    if (count >= 20 && count < 25) return '4 ido ama 4 ari';
    if (count >= 25 && count < 36) {
      return '1 neef geel dhedig ah oo hal sano jirsatay (bint makaad)';
    }
    if (count >= 36 && count < 46) {
      return '1 neef geel dhedig ah oo laba sano jirsatay (bint laboon)';
    }
    if (count >= 46 && count < 61) {
      return '1 neef geel dhedig ah oo saddex sano jirsatay (hiqqa)';
    }
    if (count >= 61 && count < 76) {
      return '1 neef geel dhedig ah oo afar sano jirsatay (jadh’a)';
    }
    if (count >= 76 && count < 91) {
      return '2 neef geel dhedig ah oo laba sano jirsatay';
    }
    if (count >= 91 && count < 121) {
      return '2 neef geel dhedig ah oo saddex sano jirsatay';
    }

    int extra = ((count - 120) / 40).floor();
    return 'Zakada waa ${extra + 3} neef geel (hal neef 40 kii neefba kadib)';
  }

  String _calculateCowZakat(double count) {
    if (count < 30) return 'ma jirto zakaa la bixinayo';

    if (count >= 30 && count < 40) {
      return '1 Weyl (Tabaah - 1 sano)';
    } else if (count >= 40 && count < 60) {
      return '1 Qaalin (Musinnah - 2 sano)';
    } else if (count >= 60 && count < 70) {
      return '2 Weyl (2 Tabaah)';
    } else if (count >= 70 && count < 80) {
      return '1 Weyl iyo 1 Qaalin';
    } else if (count >= 80 && count < 90) {
      return '2 Qaalin (2 Musinnah)';
    } else if (count >= 90 && count < 100) {
      return '3 Weyl (3 Tabaah)';
    } else if (count >= 100 && count < 110) {
      return '2 Weyl iyo 1 Qaalin';
    } else if (count >= 110 && count < 120) {
      return '1 Weyl iyo 2 Qaalin';
    } else {
      // 120 cows or more
      double remaining = count;
      int tabaahCount = 0;
      int musinnahCount = 0;

      // You can pay either using groups of 30 (Tabaah) or 40 (Musinnah)
      while (remaining >= 40) {
        musinnahCount++;
        remaining -= 40;
      }

      while (remaining >= 30) {
        tabaahCount++;
        remaining -= 30;
      }

      // After distributing, check which combination minimizes leftover
      if (remaining >= 0 && remaining < 30) {
        if (tabaahCount > 0) {
          // try to replace one musinnah with two tabaah if needed
          if (remaining + 40 >= 60) {
            musinnahCount--;
            tabaahCount += 2;
            remaining = remaining + 40 - 60;
          }
        }
      }

      String result = '';
      if (tabaahCount > 0) result += '$tabaahCount Weyl';
      if (tabaahCount > 0 && musinnahCount > 0) result += ' iyo ';
      if (musinnahCount > 0) result += '$musinnahCount Qaalin';

      return result.isNotEmpty
          ? result
          : 'Xisaabinta zakada ee tiradan lama fulin';
    }
  }

  String _calculateSheepZakat(double count) {
    if (count < 40) return 'ma jirto zakaa la bixinayo';
    if (count <= 120) return '1 ido ama 1 ari';
    if (count <= 200) return '2 ido ama 2 ari';
    int extra = ((count - 200) ~/ 100);
    return '${2 + extra} ido ama ari';
  }
}
