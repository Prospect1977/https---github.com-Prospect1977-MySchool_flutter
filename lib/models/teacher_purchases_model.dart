import 'package:intl/intl.dart';

class TeacherPurchases {
  List<Record> Records = [];
  TeacherPurchases.fromJson(List<Object> js) {
    js.forEach((element) {
      Records.add(Record.fromJson(element));
    });
  }
}

class Record {
  String dataDate;
  dynamic totalPurchases;
  dynamic totalAmount;
  List<Items> items;
  Record.fromJson(Map<String, dynamic> json) {
    dataDate = json['dataDate'];
    totalPurchases = json['totalPurchases'];
    totalAmount = json['totalAmount'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items.add(new Items.fromJson(v));
      });
    }
  }
}

class Items {
  String yearOfStudy;
  String subjectName;
  String dir;
  String lessonName;
  int lessonId;
  int yearSubjectId;
  int termIndex;
  int count;
  dynamic amount;
  Items.fromJson(Map<String, dynamic> json) {
    yearOfStudy = json['yearOfStudy'];
    subjectName = json['subjectName'];
    dir = json['dir'];
    lessonName = json['lessonName'];
    lessonId = json['lessonId'];
    yearSubjectId = json['yearSubjectId'];
    termIndex = json['termIndex'];
    count = json['count'];
    amount = json['amount'];
  }
}

class TeacherPurchasesTotals {
  int totalPurchasesCount;
  dynamic totalPurchasesAmount;
  TeacherPurchasesTotals.fromJson(Map<String, dynamic> json) {
    totalPurchasesCount = json['totalPurchasesCount'];
    totalPurchasesAmount = json['totalPurchasesAmount'];
  }
}

//------------------------------------- linear chart
class purchaseItem {
  String dataDate;
  dynamic totalAmount;
  purchaseItem.fromJson(Map<String, dynamic> js) {
    dataDate =
        DateFormat("d MMM").format(DateTime.parse(js["dataDate"])).toString();
    totalAmount = js["totalAmount"].toDouble();
  }
}

class TeacherPurchasesOverTime {
  List<purchaseItem> items = [];

  TeacherPurchasesOverTime.fromJson(List<Object> js) {
    js.forEach((element) {
      items.add(purchaseItem.fromJson(element));
    });
  }
}
