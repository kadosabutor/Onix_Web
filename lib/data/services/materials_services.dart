import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialsServices {
  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getMaterials(
    String projectId,
  ) {
    return FirebaseFirestore.instance
        .collection('materials')
        .where('projectId', isEqualTo: projectId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}
