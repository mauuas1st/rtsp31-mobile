// class UserModels {
//   final int id;
//   final String employeeId;
//   final int roleId;
//   final String name;
//   final String nickname;
//   final String email;
//   final String emailVerifiedAt;
//   final String education;
//   final String major;
//   final String title;
//   final String companyName;
//   final int departmentId;
//   final int jobPositionId;
//   final String phoneNumber;
//   final String photo;
//   final String nik;
//   final String address;
//   final String gender;
//   final String birthDate;
//   final int age;
//   final String birthPlace;
//   final String religion;
//   final String language;
//   final String maritalStatus;
//   final int numberOfChildren;
//   final String homeWorkDistance;
//   final String bankAccount;
//   final String npwp;
//   final String bpjsTk;
//   final String bpjs;
//   final String facebook;
//   final String instagram;
//   final String employeeStatus;
//   final String createdAt;
//   final String updatedAt;

//   UserModels({
//     required this.id,
//     required this.employeeId,
//     required this.roleId,
//     required this.name,
//     required this.nickname,
//     required this.email,
//     required this.emailVerifiedAt,
//     required this.education,
//     required this.major,
//     required this.title,
//     required this.companyName,
//     required this.departmentId,
//     required this.jobPositionId,
//     required this.phoneNumber,
//     required this.photo,
//     required this.nik,
//     required this.address,
//     required this.gender,
//     required this.birthDate,
//     required this.age,
//     required this.birthPlace,
//     required this.religion,
//     required this.language,
//     required this.maritalStatus,
//     required this.numberOfChildren,
//     required this.homeWorkDistance,
//     required this.bankAccount,
//     required this.npwp,
//     required this.bpjsTk,
//     required this.bpjs,
//     required this.facebook,
//     required this.instagram,
//     required this.employeeStatus,
//     required this.createdAt,
//     required this.updatedAt,
//   });

//   factory UserModels.fromJson(Map<String, dynamic> json) {
//     return UserModels(
//       id: json['id'],
//       employeeId: json['employee_id'],
//       roleId: json['role_id'],
//       name: json['name'],
//       nickname: json['nickname'],
//       email: json['email'],
//       emailVerifiedAt: json['email_verified_at'],
//       education: json['education'],
//       major: json['major'],
//       title: json['title'],
//       companyName: json['company_name'],
//       departmentId: json['department_id'],
//       jobPositionId: json['job_position_id'],
//       phoneNumber: json['phone_number'],
//       photo: json['photo'],
//       nik: json['nik'],
//       address: json['address'],
//       gender: json['gender'],
//       birthDate: json['birth_date'],
//       age: json['age'],
//       birthPlace: json['birth_place'],
//       religion: json['religion'],
//       language: json['language'],
//       maritalStatus: json['marital_status'],
//       numberOfChildren: json['number_of_children'],
//       homeWorkDistance: json['home_work_distance'],
//       bankAccount: json['bank_account'],
//       npwp: json['npwp'],
//       bpjsTk: json['bpjs_tk'],
//       bpjs: json['bpjs'],
//       facebook: json['facebook'],
//       instagram: json['instagram'],
//       employeeStatus: json['employee_status'],
//       createdAt: json['created_at'],
//       updatedAt: json['updated_at'],
//     );
//   }
// }

class UserModels {
  final int id;
  final String employeeId;
  final int roleId;
  final String name;
  final String nickname;
  final String email;
  final String? emailVerifiedAt;
  final String? education;
  final String? major;
  final String? title;
  final int? companyId; // ganti: dari companyName jadi companyId (int?)
  final int? departmentId; // nullable
  final int? jobPositionId; // nullable
  final String phoneNumber;
  final String photo;
  final String nik;
  final String address;
  final String gender;
  final String birthDate;
  final int? age; // nullable
  final String birthPlace;
  final String religion;
  final String language;
  final String maritalStatus;
  final int? numberOfChildren; // nullable
  final String homeWorkDistance;
  final String bankAccount;
  final String npwp;
  final String bpjsTk;
  final String bpjs;
  final String facebook;
  final String instagram;
  final String employeeStatus;
  final String createdAt;
  final String updatedAt;

  UserModels({
    required this.id,
    required this.employeeId,
    required this.roleId,
    required this.name,
    required this.nickname,
    required this.email,
    this.emailVerifiedAt,
    this.education,
    this.major,
    this.title,
    this.companyId,
    this.departmentId,
    this.jobPositionId,
    required this.phoneNumber,
    required this.photo,
    required this.nik,
    required this.address,
    required this.gender,
    required this.birthDate,
    this.age,
    required this.birthPlace,
    required this.religion,
    required this.language,
    required this.maritalStatus,
    this.numberOfChildren,
    required this.homeWorkDistance,
    required this.bankAccount,
    required this.npwp,
    required this.bpjsTk,
    required this.bpjs,
    required this.facebook,
    required this.instagram,
    required this.employeeStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModels.fromJson(Map<String, dynamic> json) {
    return UserModels(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? '',
      roleId: json['role_id'] ?? 0,
      name: json['name'] ?? '',
      nickname: json['nickname'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      education: json['education'],
      major: json['major'],
      title: json['title'],
      companyId: json['company_id'], // ✅ fix
      departmentId: json['department_id'], // ✅ nullable
      jobPositionId: json['job_position_id'], // ✅ nullable
      phoneNumber: json['phone_number'] ?? '',
      photo: json['photo'] ?? '',
      nik: json['nik'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      birthDate: json['birth_date'] ?? '',
      age: json['age'], // ✅ nullable
      birthPlace: json['birth_place'] ?? '',
      religion: json['religion'] ?? '',
      language: json['language'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      numberOfChildren: json['number_of_children'], // ✅ nullable
      homeWorkDistance: json['home_work_distance'] ?? '',
      bankAccount: json['bank_account'] ?? '',
      npwp: json['npwp'] ?? '',
      bpjsTk: json['bpjs_tk'] ?? '',
      bpjs: json['bpjs'] ?? '',
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      employeeStatus: json['employee_status'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
