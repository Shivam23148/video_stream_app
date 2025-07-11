/* class GroupModel {
  final int groupId;
  final String location;
  final String city;
  final String area;
  final List<CamerasModel> cameras;

  GroupModel({
    required this.groupId,
    required this.location,
    required this.city,
    required this.area,
    required this.cameras,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    var cameraList = <CamerasModel>[];
    if (json['camera'] != null) {
      cameraList = (json['cameras'] as List)
          .map((cam) => CamerasModel.fromJson(cam))
          .toList();
    }
    return GroupModel(
      groupId: json['id'] ?? 0,
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      area: json['area_name'] ?? '',
      cameras: cameraList,
    );
  }
} 

class CamerasModel {
  final String cameraName;

  CamerasModel({required this.cameraName});

  factory CamerasModel.fromJson(Map<String, dynamic> json) {
    return CamerasModel(cameraName: json['camera_name']);
  }
}
*/

class CamerasModel {
  final int groupId;
  final int cameraId;
  final String cameraName;
  final String location;
  final String area;
  final String city;

  CamerasModel({
    required this.groupId,
    required this.cameraId,
    required this.cameraName,
    required this.location,
    required this.area,
    required this.city,
  });

  factory CamerasModel.fromJson(Map<String, dynamic> json, int groupId) {
    final groupDetails = json['group_detail'] ?? {};
    return CamerasModel(
      groupId: groupId,
      cameraId: json['id'],
      cameraName: json['camera_name'] ?? 'No Name',
      location: groupDetails['location'] ?? '',
      area: groupDetails['area_name'] ?? '',
      city: groupDetails['city'] ?? '',
    );
  }
}
