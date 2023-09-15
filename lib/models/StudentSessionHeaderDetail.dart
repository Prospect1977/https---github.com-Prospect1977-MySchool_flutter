class AllData {
  SessionHeader sessionHeader;
  List<SessionDetails> sessionDetails;
  AllData.fromJson(Map<String, dynamic> json) {
    sessionHeader = json['sessionHeader'] != null
        ? new SessionHeader.fromJson(json['sessionHeader'])
        : null;
    if (json['sessionDetails'] != null) {
      sessionDetails = <SessionDetails>[];
      json['sessionDetails'].forEach((v) {
        sessionDetails.add(new SessionDetails.fromJson(v));
      });
    }
  }
}

class SessionHeader {
  int price;
  bool isFree;
  bool isPurchaseExist;
  bool isPurchaseCompleted;
  String source;
  int kioskNumber;
  dynamic studentRate;
  SessionHeader.fromJson(Map<String, dynamic> json) {
    price = json['price'];
    isFree = json['isFree'] == null ? true : json['isFree'];
    isPurchaseExist = json['isPurchaseExist'];
    isPurchaseCompleted = json['isPurchaseCompleted'];
    source = json['source'];
    kioskNumber = json['kioskNumber'];
    studentRate = json['studentRate'];
  }
}

class SessionDetails {
  String type;
  int id;
  bool isDisabled;
  int documentId;
  int videoId;
  int quizId;
  String title;
  String videoUrl;
  dynamic aspectRatio;
  String videoCover;
  dynamic documentUrl;
  dynamic videoProgress;
  dynamic quizProgress;
  dynamic quizDegree;
  dynamic videoStoppedAt;
  String urlSource;
  String coverUrlSource;
  int duration;

  SessionDetails.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    id = json['id'];
    isDisabled = json['isDisabled'];
    documentId = json['documentId'];
    videoId = json['videoId'];
    quizId = json['quizId'];
    title = json['title'];
    videoUrl = json['videoUrl'];
    try {
      aspectRatio = json['width'] / json['height'];
    } catch (e) {
      aspectRatio = 1.0;
    }

    videoCover = json['videoCover'];
    coverUrlSource = json['coverUrlSource'];
    documentUrl = json['documentUrl'];
    videoProgress = json['videoProgress'];
    quizProgress = json['quizProgress'];
    quizDegree = json['quizDegree'];
    videoStoppedAt = json['videoStoppedAt'];
    urlSource = json['urlSource'];
    duration = json['duration'];
  }
}
