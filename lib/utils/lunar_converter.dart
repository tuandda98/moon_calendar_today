import 'dart:math';

class LunarDate {
  final int day;
  final int month;
  final int year;
  final bool isLeapMonth;

  const LunarDate({
    required this.day,
    required this.month,
    required this.year,
    this.isLeapMonth = false,
  });

  @override
  String toString() => '$day/$month/$year${isLeapMonth ? " (nhuận)" : ""}';

  @override
  bool operator ==(Object other) =>
      other is LunarDate &&
      day == other.day &&
      month == other.month &&
      year == other.year &&
      isLeapMonth == other.isLeapMonth;

  @override
  int get hashCode => Object.hash(day, month, year, isLeapMonth);
}

class LunarConverter {
  static const double _timeZone = 7.0; // Vietnam UTC+7

  static int _jdFromDate(int dd, int mm, int yy) {
    int a = (14 - mm) ~/ 12;
    int y = yy + 4800 - a;
    int m = mm + 12 * a - 3;
    int jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - y ~/ 100 + y ~/ 400 - 32045;
    if (jd < 2299161) {
      jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    return jd;
  }

  static List<int> _jdToDate(int jd) {
    int a, b, c;
    if (jd > 2299160) {
      a = jd + 32044;
      b = (4 * a + 3) ~/ 146097;
      c = a - (b * 146097) ~/ 4;
    } else {
      b = 0;
      c = jd + 32082;
    }
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d) ~/ 4;
    int m = (5 * e + 2) ~/ 153;
    int day = e - (153 * m + 2) ~/ 5 + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = b * 100 + d - 4800 + m ~/ 10;
    return [day, month, year];
  }

  static int _getNewMoonDay(int k, double timeZone) {
    const double dr = pi / 180;
    double T = k / 1236.85;
    double T2 = T * T;
    double T3 = T2 * T;
    double Jd1 = 2415020.75933 + 29.53058868 * k + 0.0001178 * T2 - 0.000000155 * T3;
    Jd1 += 0.00033 * sin((166.56 + 132.87 * T - 0.009173 * T2) * dr);
    double M = 357.5291 + 35999.0503 * T - 0.0001559 * T2 - 0.00000048 * T3;
    double Mpr = 306.0253 + 385.81691806 * k + 0.0107306 * T2 + 0.00001236 * T3;
    double F = 21.2964 + 390.67050646 * k - 0.0016528 * T2 - 0.00000239 * T3;
    double C1 = (0.1734 - 0.000393 * T) * sin(M * dr) + 0.0021 * sin(2 * dr * M);
    C1 -= 0.4068 * sin(Mpr * dr) + 0.0161 * sin(2 * dr * Mpr);
    C1 -= 0.0004 * sin(3 * dr * Mpr);
    C1 += 0.0104 * sin(2 * dr * F) - 0.0051 * sin((M + Mpr) * dr);
    C1 -= 0.0074 * sin((M - Mpr) * dr) + 0.0004 * sin((2 * F + M) * dr);
    C1 -= 0.0004 * sin((2 * F - M) * dr) - 0.0006 * sin((2 * F + Mpr) * dr);
    C1 += 0.0010 * sin((2 * F - Mpr) * dr) + 0.0005 * sin((M + 2 * Mpr) * dr);
    double deltaT;
    if (T < -11) {
      deltaT = 0.001 + 0.000839 * T + 0.0002261 * T2 - 0.00000845 * T3 - 0.000000081 * T * T3;
    } else {
      deltaT = -0.000278 + 0.000265 * T + 0.000262 * T2;
    }
    double JdNew = Jd1 + C1 - deltaT;
    return (JdNew + 0.5 + timeZone / 24).floor();
  }

  static int _getSunLongitude(int jdn, double timeZone) {
    const double dr = pi / 180;
    double T = (jdn - 2451545.5 - timeZone / 24) / 36525;
    double T2 = T * T;
    double M = 357.5291 + 35999.0503 * T - 0.0001559 * T2 - 0.00000048 * T * T2;
    double L0 = 280.46645 + 36000.76983 * T + 0.0003032 * T2;
    double DL = (1.9146 - 0.004817 * T - 0.000014 * T2) * sin(dr * M);
    DL += (0.019993 - 0.000101 * T) * sin(dr * 2 * M) + 0.00029 * sin(dr * 3 * M);
    double L = L0 + DL;
    double L1 = L * dr;
    L1 = L1 - pi * 2 * ((L1 / (pi * 2)).floor());
    return (L1 / pi * 6).floor();
  }

  static int _getLunarMonth11(int yy, double timeZone) {
    double off = _jdFromDate(31, 12, yy) - 2415021.076998695;
    int k = (off / 29.530588853).floor();
    int nm = _getNewMoonDay(k, timeZone);
    int sunLong = _getSunLongitude(nm, timeZone);
    if (sunLong >= 9) {
      nm = _getNewMoonDay(k - 1, timeZone);
    }
    return nm;
  }

  static int _getLeapMonthOffset(int a11, double timeZone) {
    int k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    int last = 0;
    int i = 1;
    int arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    do {
      last = arc;
      i++;
      arc = _getSunLongitude(_getNewMoonDay(k + i, timeZone), timeZone);
    } while (arc != last && i < 14);
    return i - 1;
  }

  static LunarDate solarToLunar(DateTime solar) {
    int dd = solar.day, mm = solar.month, yy = solar.year;
    int dayNumber = _jdFromDate(dd, mm, yy);
    int k = ((dayNumber - 2415021.076998695) / 29.530588853).floor();
    int monthStart = _getNewMoonDay(k + 1, _timeZone);
    if (monthStart > dayNumber) {
      monthStart = _getNewMoonDay(k, _timeZone);
    }
    int a11 = _getLunarMonth11(yy, _timeZone);
    int b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = yy;
      a11 = _getLunarMonth11(yy - 1, _timeZone);
    } else {
      lunarYear = yy + 1;
      b11 = _getLunarMonth11(yy + 1, _timeZone);
    }
    int lunarDay = dayNumber - monthStart + 1;
    int diff = ((monthStart - a11) / 29).floor();
    bool lunarLeap = false;
    int lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      int leapMonthDiff = _getLeapMonthOffset(a11, _timeZone);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) {
          lunarLeap = true;
        }
      }
    }
    if (lunarMonth > 12) {
      lunarMonth -= 12;
    }
    if (lunarMonth >= 11 && diff < 4) {
      lunarYear -= 1;
    }
    return LunarDate(
      day: lunarDay,
      month: lunarMonth,
      year: lunarYear,
      isLeapMonth: lunarLeap,
    );
  }

  static DateTime? lunarToSolar(int lunarDay, int lunarMonth, int lunarYear, {bool isLeap = false}) {
    int a11, b11;
    if (lunarMonth < 11) {
      a11 = _getLunarMonth11(lunarYear - 1, _timeZone);
      b11 = _getLunarMonth11(lunarYear, _timeZone);
    } else {
      a11 = _getLunarMonth11(lunarYear, _timeZone);
      b11 = _getLunarMonth11(lunarYear + 1, _timeZone);
    }
    int k = ((a11 - 2415021.076998695) / 29.530588853 + 0.5).floor();
    int off = lunarMonth - 11;
    if (off < 0) off += 12;
    if (b11 - a11 > 365) {
      int leapOff = _getLeapMonthOffset(a11, _timeZone);
      int leapMonth = leapOff - 2;
      if (leapMonth < 0) leapMonth += 12;
      if (isLeap && lunarMonth != leapMonth) {
        return null;
      } else if (isLeap || off >= leapOff) {
        off += 1;
      }
    }
    int monthStart = _getNewMoonDay(k + off, _timeZone);
    List<int> date = _jdToDate(monthStart + lunarDay - 1);
    return DateTime(date[2], date[1], date[0]);
  }

  static double getMoonPhase(DateTime solar) {
    final lunar = solarToLunar(solar);
    return (lunar.day - 1) / 29.5;
  }

  static String getMoonPhaseName(double phase) {
    if (phase < 0.03 || phase >= 0.97) return 'Trăng mới';
    if (phase < 0.22) return 'Trăng khuyết đầu';
    if (phase < 0.28) return 'Bán nguyệt đầu';
    if (phase < 0.47) return 'Trăng thượng huyền';
    if (phase < 0.53) return 'Trăng tròn';
    if (phase < 0.72) return 'Trăng khuyết cuối';
    if (phase < 0.78) return 'Bán nguyệt cuối';
    return 'Trăng hạ huyền';
  }

  static bool isSpecialDay(LunarDate lunar) {
    return lunar.day == 1 || lunar.day == 15;
  }

  static String getSpecialDayName(LunarDate lunar) {
    if (lunar.day == 1) return 'Mùng 1 - Đầu tháng';
    if (lunar.day == 15) return 'Rằm tháng ${lunar.month}';
    return '';
  }

  static String getCanChiYear(int lunarYear) {
    const can = ['Canh', 'Tân', 'Nhâm', 'Quý', 'Giáp', 'Ất', 'Bính', 'Đinh', 'Mậu', 'Kỷ'];
    const chi = ['Thân', 'Dậu', 'Tuất', 'Hợi', 'Tý', 'Sửu', 'Dần', 'Mão', 'Thìn', 'Tỵ', 'Ngọ', 'Mùi'];
    return '${can[lunarYear % 10]} ${chi[lunarYear % 12]}';
  }

  static String getMonthName(int month) {
    if (month == 1) return 'Tháng Giêng';
    return 'Tháng $month';
  }
}
