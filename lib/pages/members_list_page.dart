import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/pocketbase_service.dart';
import '../models.dart';
import 'edit_member_page.dart';

class MembersController extends GetxController {
  final PBService service;
  MembersController(this.service);

  final members = <Member>[].obs;
  final loading = false.obs;
  final query = ''.obs; // 🔎 เพิ่ม state สำหรับช่องค้นหา

  Future<void> fetch() async {
    loading.value = true;
    try {
      members.value = await service.listMembers();
    } finally {
      loading.value = false;
    }
  }

  List<Member> get filteredMembers {
    if (query.value.isEmpty) return members;
    final q = query.value.toLowerCase();
    return members.where((m) => m.name.toLowerCase().contains(q)).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }
}

class MembersListPage extends StatelessWidget {
  final MembersController c = Get.put(MembersController(PBService('http://127.0.0.1:8090')));

  MembersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => c.fetch(),
          ),
        ],
      ),

      // 🔍 ช่องค้นหา + รายชื่อ
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ค้นหารายชื่อสมาชิก...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => c.query.value = value,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (c.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final members = c.filteredMembers;
              if (members.isEmpty) {
                return const Center(child: Text('ไม่พบสมาชิกที่ค้นหา', style: TextStyle(color: Colors.white70)));
              }
              return RefreshIndicator(
                onRefresh: () => c.fetch(),
                color: Colors.white,
                backgroundColor: Colors.grey[800],
                child: ListView.separated(
                  itemCount: members.length,
                  separatorBuilder: (_, __) => Divider(color: Colors.grey[700]),
                  itemBuilder: (_, i) {
                    final m = members[i];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      title: Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      subtitle: Text(
                        '${m.email} • ${m.role}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[700],
                        child: Text(
                          m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      trailing: const Icon(Icons.edit, color: Colors.white70), // ✏️ ปรับไอคอนด้านขวา
                      onTap: () => Get.to(() => EditMemberPage(memberId: m.id))!.then((_) => c.fetch()),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),

      // ➕ ปุ่มเพิ่มสมาชิก
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.grey[800],
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('เพิ่มสมาชิก', style: TextStyle(color: Colors.white)),
        onPressed: () async {
          final newMember = Member(
            id: 'tmp',
            name: 'New User',
            email: 'new.user.${DateTime.now().millisecondsSinceEpoch}@example.com',
            role: 'Intern',
            created: DateTime.now(),
            updated: DateTime.now(),
          );
          await c.service.createMember(newMember);
          await c.fetch();
        },
      ),
    );
  }
}
