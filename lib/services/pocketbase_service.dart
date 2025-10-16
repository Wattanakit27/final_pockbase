import 'package:pocketbase/pocketbase.dart';
import '../models.dart';

class PBService {
  final PocketBase pb;
  PBService(String baseUrl) : pb = PocketBase(baseUrl);

  Future<List<Member>> listMembers() async {
    final result = await pb.collection('members').getList(page: 1, perPage: 50);
    return result.items.map(Member.fromRecord).toList();
  }

  Future<Member> createMember(Member m) async {
    final r = await pb.collection('members').create(body: m.toJson());
    return Member.fromRecord(r);
  }

  Future<Member> updateMember(Member m) async {
    final r = await pb.collection('members').update(m.id, body: m.toJson());
    return Member.fromRecord(r);
  }

  Future<void> deleteMember(String id) async {
    await pb.collection('members').delete(id);
  }
}
