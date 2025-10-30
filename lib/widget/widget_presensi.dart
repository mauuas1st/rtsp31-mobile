// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:rtsp31_mobile/constants/app_color.dart';
// import 'package:rtsp31_mobile/models/presensi.dart';
// import 'package:rtsp31_mobile/pages/attendance_page_copy.dart';

// Widget buildTopCard(BuildContext context, PresensiModel firstItem) {
//   String calculateDuration(PresensiModel attendance) {
//     if (attendance.checkInTime == null || attendance.checkOutTime == null) {
//       return '0 jam';
//     }
//     final duration = attendance.checkOutTime!.difference(
//       attendance.checkInTime!,
//     );
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     return '$hours jam $minutes menit';
//   }

//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//       boxShadow: [
//         BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(
//           child: Column(
//             children: [
//               const SizedBox(height: 14),
//               Text(
//                 DateFormat('dd MMMM yyyy').format(firstItem.checkInTime!),
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${firstItem.checkInTime != null ? DateFormat('HH:mm').format(firstItem.checkInTime!) : '00:00'} - '
//                 '${firstItem.checkOutTime != null ? DateFormat('HH:mm').format(firstItem.checkOutTime!) : '00:00'}',
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 'Total Jam Kerja : ${calculateDuration(firstItem)}',
//                 style: const TextStyle(fontSize: 14),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: 250,
//                 child: Card(
//                   color: AppColors.colorPrimary,
//                   elevation: 2,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ListTile(
//                     title: const Text(
//                       "Tugas",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     onTap: () {
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => AttendancePageCopy(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget buildRiwayatList({
//   required BuildContext context,
//   required List<PresensiModel> attendances,
//   required ScrollController scrollController,
//   required bool isLoading,
// }) {
//   double historyHeight = MediaQuery.of(context).size.height * 0.5;

//   int itemCount = 0;
//   bool isInitialLoading = attendances.isEmpty && isLoading;

//   if (isInitialLoading) {
//     // FULL SKELETON LIST (loading awal)
//     itemCount = 6;
//   } else {
//     // Tambahkan 3 skeleton di bawah data saat load more
//     itemCount = attendances.length + (isLoading ? 3 : 0);
//   }

//   return Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 16),
//     child: Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(16),
//           topRight: Radius.circular(16),
//         ),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Center(
//             child: Text(
//               "Riwayat",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ),
//           const SizedBox(height: 8),

//           if (!isLoading && attendances.isEmpty)
//             SizedBox(
//               height: historyHeight,
//               child: const Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.history, size: 48, color: Colors.grey),
//                     SizedBox(height: 12),
//                     Text(
//                       "Belum ada kehadiran",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             SizedBox(
//               height: historyHeight,
//               child: ListView.builder(
//                 controller: scrollController,
//                 itemCount: itemCount,
//                 itemBuilder: (context, index) {
//                   bool isSkeleton =
//                       (isInitialLoading) ||
//                       (index >= attendances.length && isLoading);

//                   if (isSkeleton) {
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 6),
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               width: 100,
//                               height: 14,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade300,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                             const SizedBox(height: 10),
//                             Container(
//                               width: double.infinity,
//                               height: 14,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade300,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                             const SizedBox(height: 6),
//                             Container(
//                               width: 140,
//                               height: 14,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey.shade300,
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }

//                   final item = attendances[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade300,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Text(
//                               item.workLocation,
//                               style: const TextStyle(fontSize: 12),
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             "Mulai: ${item.checkInTime != null ? DateFormat('HH:mm').format(item.checkInTime!) : "-"} WIB",
//                           ),
//                           Text(
//                             "Selesai: ${item.checkOutTime != null ? DateFormat('HH:mm').format(item.checkOutTime!) : "-"} WIB",
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Text(
//                                 '${item.employeeId} - ',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               Text(
//                                 DateFormat(
//                                   'dd MMMM yyyy',
//                                 ).format(item.checkInTime!),
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//     ),
//   );
// }
