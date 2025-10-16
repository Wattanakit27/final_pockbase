import 'package:pocketbase/pocketbase.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String role;
  final DateTime created;
  final DateTime updated;

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.created,
    required this.updated,
  });

  factory Member.fromRecord(RecordModel r) {
    return Member(
      id: r.id,
      name: r.data['name'] ?? '',
      email: r.data['email'] ?? '',
      role: r.data['role'] ?? '',
      created: DateTime.tryParse(r.created) ?? DateTime.now(),
      updated: DateTime.tryParse(r.updated) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'role': role,
      };
}
