class PresensiModel {
  final int id;
  final String employeeId;
  final String employeeName;
  final int shift;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int lateMinutes;
  final String workLocation;
  final String workHours;
  final String actualWorkHours;
  final int earlyCheckIn;
  final int earlyCheckOut;
  final String overtimeDuration;
  final String insufficientDuration;
  final String breakDuration;
  final double? latitudeIn;
  final double? longitudeIn;
  final String checkInAddress;
  final String checkInMapLink;
  final double? latitudeOut;
  final double? longitudeOut;
  final String checkOutAddress;
  final String checkOutMapLink;
  final String? loadingLocation;
  final String? unloadingLocation;
  final String? checkInNote;
  final String? checkOutNote;
  final String checkInPhotoPath;
  final String checkOutPhotoPath;
  final String checkInToolPhotoPath;
  final String checkOutToolPhotoPath;
  final String? heavyEquipmentId;
  final String projectName;
  final DateTime? createdAt;
  final DateTime updatedAt;

  PresensiModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.shift,
    required this.checkInTime,
    required this.checkOutTime,
    required this.lateMinutes,
    required this.workLocation,
    required this.workHours,
    required this.actualWorkHours,
    required this.earlyCheckIn,
    required this.earlyCheckOut,
    required this.overtimeDuration,
    required this.insufficientDuration,
    required this.breakDuration,
    required this.latitudeIn,
    required this.longitudeIn,
    required this.checkInAddress,
    required this.checkInMapLink,
    required this.latitudeOut,
    required this.longitudeOut,
    required this.checkOutAddress,
    required this.checkOutMapLink,
    required this.checkInNote,
    required this.loadingLocation,
    required this.unloadingLocation,
    required this.checkOutNote,
    required this.checkInPhotoPath,
    required this.checkOutPhotoPath,
    required this.checkInToolPhotoPath,
    required this.checkOutToolPhotoPath,
    required this.heavyEquipmentId,
    required this.projectName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      employeeName: json['employee_name'] ?? '',
      shift: json['shift'] ?? 1,
      checkInTime:
          json['check_in_time'] != null && json['check_in_time'] != ''
              ? DateTime.tryParse(json['check_in_time'])
              : null,
      // checkInTime: DateTime.parse(json['check_in_time'] ?? ''),
      checkOutTime:
          json['check_out_time'] != null && json['check_out_time'] != ''
              ? DateTime.tryParse(json['check_out_time'])
              : null,
      // checkOutTime: DateTime.parse(json['check_out_time'] ?? ''),
      lateMinutes: json['late_minutes'] ?? 0,
      workLocation: json['work_location'] ?? '-',
      // workLocation: json['work_location'] ?? '',
      workHours: json['work_hours'] ?? '',
      actualWorkHours: json['actual_work_hours'] ?? '',
      earlyCheckIn: json['early_check_in'] ?? 0,
      earlyCheckOut: json['early_check_out'] ?? 0,
      overtimeDuration: json['overtime_duration'] ?? '',
      insufficientDuration: json['insufficient_duration'] ?? '',
      breakDuration: json['break_duration'] ?? '',
      latitudeIn: (json['latitude_in'] ?? 0).toDouble(),
      longitudeIn: (json['longitude_in'] ?? 0).toDouble(),
      checkInAddress: json['check_in_address'] ?? '',
      checkInMapLink: json['check_in_map_link'] ?? '',
      latitudeOut: (json['latitude_out'] ?? 0).toDouble(),
      longitudeOut: (json['longitude_out'] ?? 0).toDouble(),
      checkOutAddress: json['check_out_address'] ?? '',
      checkOutMapLink: json['check_out_map_link'] ?? '',
      loadingLocation: json['loading_location'],
      unloadingLocation: json['unloading_location'],
      checkInNote: json['check_in_note'],
      checkOutNote: json['check_out_note'],
      checkInPhotoPath: json['check_in_photo_path'] ?? '',
      checkOutPhotoPath: json['check_out_photo_path'] ?? '',
      checkInToolPhotoPath: json['check_in_arround_photo_path'] ?? '',
      checkOutToolPhotoPath: json['check_out_arround_photo_path'] ?? '',
      heavyEquipmentId: json['heavy_equipment_id'] ?? '',
      projectName: json['project_name'] ?? '',
      createdAt:
          json['created_at'] != null && json['created_at'] != ''
              ? DateTime.tryParse(json['created_at'])
              : null,
      // createdAt: DateTime.parse(json['created_at'] ?? ''),
      updatedAt: DateTime.parse(json['updated_at'] ?? ''),
    );
  }

  // factory PresensiModel.empty() {
  //   return PresensiModel(
  //     id: 0,
  //     employeeId: '',
  //     employeeName: '',
  //     shift: 0,
  //     checkInTime: null,
  //     checkOutTime: null,
  //     lateMinutes: 0,
  //     workLocation: '-',
  //     workHours: '',
  //     actualWorkHours: '',
  //     earlyCheckIn: 0,
  //     earlyCheckOut: 0,
  //     overtimeDuration: '',
  //     insufficientDuration: '',
  //     breakDuration: '',
  //     latitudeIn: 0.0,
  //     longitudeIn: 0.0,
  //     checkInAddress: '',
  //     checkInMapLink: '',
  //     latitudeOut: 0.0,
  //     longitudeOut: 0.0,
  //     checkOutAddress: '',
  //     checkOutMapLink: '',
  //     checkInNote: null,
  //     checkOutNote: null,
  //     checkInPhotoPath: '',
  //     checkOutPhotoPath: '',
  //     checkInToolPhotoPath: '',
  //     checkOutToolPhotoPath: '',
  //     heavyEquipmentId: '',
  //     projectName: '',
  //     createdAt: DateTime.now(),
  //     updatedAt: DateTime.now(),
  //   );
  // }
}
