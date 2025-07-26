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
