import 'package:flutter/material.dart';

final Color primaryColor = HexColor.fromHex('#144787');
final Color secondaryColor = HexColor.fromHex('#FD9202');
final Color thirdColor = HexColor.fromHex('#FFFFFF');
final Color fourthColor = HexColor.fromHex('#000000');
final Color darkblack = HexColor.fromHex('#121212');
final Color grey1 = HexColor.fromHex('#E0E0E0');
final Color grey2 = HexColor.fromHex('#D0D0D0');
final Color grey3 = HexColor.fromHex('#616161');
final Color grey4 = HexColor.fromHex('#EAE6E6');

final Color offerColor = HexColor.fromHex('#1CBCAE');
final Color tsecondary = HexColor.fromHex('#FFD022');
final Color ttext = HexColor.fromHex('#504E4F');
final Color ttext2 = HexColor.fromHex('#696768');
final Color Cprimary = HexColor.fromHex('#23625F');
final Color Cbottom = HexColor.fromHex('#FFCE1A');
final Color White = HexColor.fromHex('#FFFFFF');
final Color Ctext2 = HexColor.fromHex('#F8F8FA');
final Color cdtext = HexColor.fromHex('#2A353A');
final Color VIPtext = HexColor.fromHex('#D61340');
final Color Cbg = HexColor.fromHex('#FCF0F0');
final Color cbg2 = HexColor.fromHex('#F1AEBB');
final Color cbg3 = HexColor.fromHex('#F28D03');
final Color cbg4 = HexColor.fromHex('#FFECD3');
final Color subtext = HexColor.fromHex('#667781');
final Color titlecolor = HexColor.fromHex('#585E64');
final Color call = HexColor.fromHex('#00AF9B');
final Color music = HexColor.fromHex('#69A9F1');
final Color eye = HexColor.fromHex('#5E7E95');
final Color oncall = HexColor.fromHex('#32965A');
final Color addcontact = HexColor.fromHex('#7881FF');
final Color play = HexColor.fromHex('#E3E8EB');
final Color textColor = HexColor.fromHex('#9B9B9B');
final Color contr1 = HexColor.fromHex('#27B9D8');
final Color contr2 = HexColor.fromHex('#7882FE');
final Color contr3 = HexColor.fromHex('#F18072');
final Color borderclr = HexColor.fromHex('#149791');
final Color paichat = HexColor.fromHex('#EDF6F6');
final Color cgreen = HexColor.fromHex('#34C650');
final Color cblack10 = HexColor.fromHex('#EFEFEF');
final Color text5 = HexColor.fromHex('#575757');
final Color cdivider = HexColor.fromHex('#85959F');
final Color iconcolor = HexColor.fromHex('#292020');

final Color color3 = HexColor.fromHex('#F0F0F0');

final Color BodyColor = HexColor.fromHex('#BACFFF');
final Color backgroundColor = HexColor.fromHex('#B1E1E1');
final Color containerBackgroundColor2 = HexColor.fromHex('#000000');
final Color approvedLeavesColor = HexColor.fromHex('#26C60C');
final Color whiteColor = HexColor.fromHex('#FFFFFF');
final Color bodyColor = HexColor.fromHex('#1FEFA7A7');
final Color vBarBgcolor = HexColor.fromHex('#F6F6F6');
final Color vBarcolor1 = HexColor.fromHex('#C1AEF1');
final Color vBarcolor2 = HexColor.fromHex('#FE8B88');
final Color vBarcolor3 = HexColor.fromHex('#48CCFF');

class ColorConst {
  static final Color border = HexColor.fromHex('#EEEEEE');
  static final Color primaryColor = HexColor.fromHex('#1564C0');
  static final Color buttonColor = HexColor.fromHex('#1564C0');
  static final Color greyTextColor = HexColor.fromHex('#9E9E9E');
  static final Color errorColor = HexColor.fromHex('#F44336');
  static final Color greenColor = HexColor.fromHex('#4CBB17');
  static final Color scafoldColor = HexColor.fromHex('#80EEEEEE');
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
