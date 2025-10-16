import 'package:faker/faker.dart';
import 'package:pocketbase/pocketbase.dart';

Future<void> main(List<String> args) async {
  final count = args.isNotEmpty ? int.tryParse(args[0]) ?? 20 : 20;
  final baseUrl = 'http://127.0.0.1:8090';

  const adminEmail = 'admin@gmail.com';
  const adminPass = 'admin12345';

  final pb = PocketBase(baseUrl);

  print('🔐 Logging in as admin...');

  try {
    await pb.collection('_superusers').authWithPassword(adminEmail, adminPass);
    print('✅ Login success! Seeding $count records...');
  } catch (e) {
    print('⚠️ Login failed with _superusers, trying old admins endpoint...');
    await pb.admins.authWithPassword(adminEmail, adminPass);
    print('✅ Login success! (old API)');
  }

  final faker = Faker();
  for (var i = 0; i < count; i++) {
    final name = faker.person.name();
    final email = faker.internet.email();
    final role = faker.job.title();

    // 👇 เปลี่ยนชื่อ collection เป็น 'users'
    await pb.collection('members').create(body: {
      'name': name,
      'email': email,
      'role': role,
    });

    print('Inserted: $name <$email> [$role]');
  }

  print('🎉 Done! Inserted $count user(s).');
}
