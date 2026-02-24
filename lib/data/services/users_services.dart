import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:okoskert_internal/data/services/get_user_team_id.dart';

class UsersServices {
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getUsers() async* {
    final teamId = await UserService.getTeamId();
    if (teamId == null || teamId.isEmpty) {
      yield [];
      return;
    }

    yield* FirebaseFirestore.instance
        .collection('users')
        .where('teamId', isEqualTo: teamId)
        .snapshots()
        .map((snapshot) => snapshot.docs.toList());
  }

  static Future<void> updateUserSalary({
    required String userId,
    required int salary,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'salary': salary,
    });
  }
}
