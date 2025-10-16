import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:faker/faker.dart';
import '../services/pocketbase_service.dart';
import '../models.dart';

class SeedMemberPage extends StatefulWidget {
  const SeedMemberPage({super.key});

  @override
  State<SeedMemberPage> createState() => _SeedMemberPageState();
}

class _SeedMemberPageState extends State<SeedMemberPage> {
  final pb = PBService('http://127.0.0.1:8090');
  final faker = Faker();

  final RxList<Member> members = <Member>[].obs;
  final RxBool loading = false.obs;
  final RxString searchQuery = ''.obs; // ✅ เพิ่มช่องค้นหา

  Future<void> loadMembers() async {
    loading.value = true;
    try {
      final data = await pb.listMembers();
      members.assignAll(data);
    } catch (e) {
      debugPrint('❌ Error loading members: $e');
    } finally {
      loading.value = false;
    }
  }

  Future<void> addRandomMember() async {
    loading.value = true;
    try {
      final m = Member(
        id: 'tmp',
        name: faker.person.name(),
        email: faker.internet.email(),
        role: faker.job.title(),
        created: DateTime.now(),
        updated: DateTime.now(),
      );
      await pb.createMember(m);
      await Future.delayed(const Duration(milliseconds: 300));
      await loadMembers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 เพิ่มสมาชิกแบบสุ่ม 1 คนแล้ว!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ เพิ่มข้อมูลล้มเหลว: $e')),
      );
    } finally {
      loading.value = false;
    }
  }

  Future<void> editMember(Member member) async {
    final nameCtrl = TextEditingController(text: member.name);
    final emailCtrl = TextEditingController(text: member.email);
    final roleCtrl = TextEditingController(text: member.role);

    final updated = await showDialog<Member>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('✏️ แก้ไขข้อมูลสมาชิก', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'ชื่อ')),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'อีเมล')),
            TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'ตำแหน่ง / บทบาท')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(
                context,
                Member(
                  id: member.id,
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                  role: roleCtrl.text,
                  created: member.created,
                  updated: DateTime.now(),
                ),
              );
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );

    if (updated != null) {
      await pb.updateMember(updated);
      await loadMembers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ แก้ไขข้อมูลสำเร็จ!')),
      );
    }
  }

  Future<void> deleteMember(Member member) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🗑️ ลบสมาชิก'),
        content: Text('คุณต้องการลบ "${member.name}" หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await pb.deleteMember(member.id);
      await loadMembers();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🗑️ ลบสมาชิก ${member.name} เรียบร้อยแล้ว!')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 🔥 dark theme
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        centerTitle: true,
        title: const Text('👥 จัดการสมาชิก', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: loadMembers,
          ),
        ],
      ),

      body: Obx(() {
        if (loading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        // 🔍 ช่องค้นหา
        final filtered = members.where((m) {
          final query = searchQuery.value.toLowerCase();
          return m.name.toLowerCase().contains(query) ||
                 m.email.toLowerCase().contains(query) ||
                 m.role.toLowerCase().contains(query);
        }).toList();

        if (members.isEmpty) {
          return const Center(
            child: Text(
              'ยังไม่มีข้อมูลสมาชิก\nกดปุ่มด้านล่างเพื่อสุ่มข้อมูล',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'ค้นหาชื่อ อีเมล หรือบทบาท...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[850],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => searchQuery.value = value,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadMembers,
                backgroundColor: Colors.grey[850],
                color: Colors.white,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final m = filtered[i];
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey[700],
                          child: Text(
                            m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(m.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${m.email}\n${m.role}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          color: Colors.grey[900],
                          icon: const Icon(Icons.more_vert, color: Colors.white70),
                          onSelected: (value) {
                            if (value == 'edit') editMember(m);
                            if (value == 'delete') deleteMember(m);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('✏️ แก้ไข')),
                            PopupMenuItem(value: 'delete', child: Text('🗑️ ลบ')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addRandomMember,
        backgroundColor: Colors.tealAccent[700],
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('เพิ่มสมาชิกแบบสุ่ม', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
