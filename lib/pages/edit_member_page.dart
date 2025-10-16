import 'package:flutter/material.dart';
import '../models.dart';
import '../services/pocketbase_service.dart';

class EditMemberPage extends StatefulWidget {
  final Member member;
  final PBService pb;

  const EditMemberPage({super.key, required this.member, required this.pb});

  @override
  State<EditMemberPage> createState() => _EditMemberPageState();
}

class _EditMemberPageState extends State<EditMemberPage> {
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController roleCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.member.name);
    emailCtrl = TextEditingController(text: widget.member.email);
    roleCtrl = TextEditingController(text: widget.member.role);
  }

  Future<void> saveChanges() async {
    final updated = Member(
      id: widget.member.id,
      name: nameCtrl.text,
      email: emailCtrl.text,
      role: roleCtrl.text,
      created: widget.member.created,
      updated: DateTime.now(),
    );

    await widget.pb.updateMember(updated);
    if (context.mounted) {
      Navigator.pop(context, true); // ✅ ส่ง true กลับไปเพื่อ refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('แก้ไขข้อมูลสมาชิก')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'ชื่อ'),
            ),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'อีเมล'),
            ),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(labelText: 'ตำแหน่ง / บทบาท'),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('บันทึกการเปลี่ยนแปลง'),
              onPressed: saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
