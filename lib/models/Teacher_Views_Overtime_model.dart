import 'package:intl/intl.dart';

class teacherViewsOverTimeModel {
  videosTraffic VideosTraffic;
  quizzesTraffic QuizzesTraffic;
  teacherViewsOverTimeModel.fromJson(Map<String, dynamic> js) {
    VideosTraffic = videosTraffic.fromJson(js["videosTraffic"]);
    QuizzesTraffic = quizzesTraffic.fromJson(js["quizzesTraffic"]);
  }
}

class trafficItem {
  String dataDate;
  double traffics;
  trafficItem.fromJson(Map<String, dynamic> js) {
    dataDate =
        DateFormat("d MMM").format(DateTime.parse(js["dataDate"])).toString();
    traffics = js["traffics"].toDouble();
  }
}

class videosTraffic {
  List<trafficItem> items = [];

  videosTraffic.fromJson(List<Object> js) {
    js.forEach((element) {
      items.add(trafficItem.fromJson(element));
    });
  }
}

class quizzesTraffic {
  List<trafficItem> items = [];

  quizzesTraffic.fromJson(List<Object> js) {
    js.forEach((element) {
      items.add(trafficItem.fromJson(element));
    });
  }
}
