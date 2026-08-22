class YoutubeStatusModel {
  final bool? isLive;
  final dynamic liveStream;
  final dynamic upcomingStream;

  YoutubeStatusModel({this.isLive, this.liveStream, this.upcomingStream});

  factory YoutubeStatusModel.fromJson(Map<String, dynamic> json) {
    return YoutubeStatusModel(
      isLive: json['isLive'],
      liveStream: json['liveStream'],
      upcomingStream: json['upcomingStream'],
    );
  }
}

class YoutubeRecentVideoModel {
  final String? id;
  final String? title;
  final String? thumbnailUrl;
  final String? duration;
  final String? publishedAt;
  final String? url;
  final Map<String, dynamic>? rawJson;

  YoutubeRecentVideoModel({
    this.id,
    this.title,
    this.thumbnailUrl,
    this.duration,
    this.publishedAt,
    this.url,
    this.rawJson,
  });

  factory YoutubeRecentVideoModel.fromJson(Map<String, dynamic> json) {
    return YoutubeRecentVideoModel(
      id: json['id'] ?? json['_id'] ?? json['videoId'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      duration: json['duration'],
      publishedAt: json['publishedAt'],
      url: json['url'] ?? json['watchUrl'] ?? json['videoUrl'],
      rawJson: json,
    );
  }
}

class ServiceInfoModel {
  final String? schedule;
  final String? time;
  final String? address;

  ServiceInfoModel({this.schedule, this.time, this.address});

  factory ServiceInfoModel.fromJson(Map<String, dynamic> json) {
    return ServiceInfoModel(
      schedule: json['schedule'],
      time: json['time'],
      address: json['address'],
    );
  }
}

class YoutubeChannelModel {
  final String? channelId;
  final String? channelTitle;
  final String? channelUrl;
  final String? subscriberCount;
  final String? thumbnailUrl;

  YoutubeChannelModel({
    this.channelId,
    this.channelTitle,
    this.channelUrl,
    this.subscriberCount,
    this.thumbnailUrl,
  });

  factory YoutubeChannelModel.fromJson(Map<String, dynamic> json) {
    return YoutubeChannelModel(
      channelId: json['channelId'],
      channelTitle: json['channelTitle'],
      channelUrl: json['channelUrl'],
      subscriberCount: json['subscriberCount'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class PlatformModel {
  final String? id;
  final String? label;
  final String? description;
  final String? icon;
  final String? color;
  final bool? isYoutube;
  final bool? isActive;
  final String? watchUrl;

  PlatformModel({
    this.id,
    this.label,
    this.description,
    this.icon,
    this.color,
    this.isYoutube,
    this.isActive,
    this.watchUrl,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      id: json['id'] ?? json['_id'],
      label: json['label'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      isYoutube: json['isYoutube'],
      isActive: json['isActive'],
      watchUrl: json['watchUrl'],
    );
  }
}
