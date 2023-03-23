int getMonthDays(int month, int year) {
  switch (month) {
    case 1:
      return 31;
      break;
    case 2:
      return year % 4 == 0 ? 28 : 29;
      break;
    case 3:
      return 31;
      break;
    case 4:
      return 30;
      break;
    case 5:
      return 31;
      break;
    case 6:
      return 30;
      break;
    case 7:
      return 31;
      break;
    case 8:
      return 31;
      break;
    case 9:
      return 30;
      break;
    case 10:
      return 31;
      break;
    case 11:
      return 30;
      break;
    case 12:
      return 31;
      break;
  }
}

String getMonthName(int month, String lang) {
  switch (month) {
    case 1:
      return lang == "en" ? "Jan." : "يناير";
      break;
    case 2:
      return lang == "en" ? "Feb." : "فبراير";
      break;
    case 3:
      return lang == "en" ? "Mars." : "مارس";
      break;
    case 4:
      return lang == "en" ? "Apr." : "إبريل";
      break;
    case 5:
      return lang == "en" ? "May." : "مايو";
      break;
    case 6:
      return lang == "en" ? "Jun." : "يونيو";
      break;
    case 7:
      return lang == "en" ? "Jul." : "يوليو";
      break;
    case 8:
      return lang == "en" ? "Aug." : "أغسطس";
      break;
    case 9:
      return lang == "en" ? "Sep." : "سبتمبر";
      break;
    case 10:
      return lang == "en" ? "Oct." : "أكتوبر";
      break;
    case 11:
      return lang == "en" ? "Nov." : "نوفمبر";
      break;
    case 12:
      return lang == "en" ? "Dec." : "ديسمبر";
      break;
  }
}

String getDayName(int day, String lang) {
  switch (day) {
    case 7:
      return lang == "en" ? "Sun." : "الأحد";
      break;
    case 1:
      return lang == "en" ? "Mon." : "الأثنين";
      break;
    case 2:
      return lang == "en" ? "Tue." : "الثلاثاء";
      break;
    case 3:
      return lang == "en" ? "Wed." : "الأربعاء";
      break;
    case 4:
      return lang == "en" ? "Thu." : "الخميس";
      break;
    case 5:
      return lang == "en" ? "Fri." : "الجمعة";
      break;
    case 6:
      return lang == "en" ? "Sat." : "السبت";
      break;
  }
}

int weekDaySundayBased(int weekDay) {
  if (weekDay == 7) {
    return 0;
  } else {
    return weekDay;
  }
}

String formatDate(DateTime dataDate, lang) {
  if (lang == "en") {
    return '${getDayName(dataDate.weekday, lang)} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}';
  } else {
    return '${getDayName(dataDate.weekday, lang)} ${dataDate.day} ${getMonthName(dataDate.month, lang)} ${dataDate.year}';
  }
}
