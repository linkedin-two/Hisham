import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edzkool/utils/colors/colors.dart';
import 'package:edzkool/utils/responsive.dart';
import 'package:edzkool/utils/Toasty.dart';
import 'package:edzkool/utils/account_deletion_service.dart';
import 'package:edzkool/providers/user_email_provider.dart';
import 'package:edzkool/screens/login/sign_up.dart';
import '../CreateProfile/education_details.dart';
import '../CreateProfile/socialLink.dart';
import '../CreateProfile/workDetails.dart';

class ProfileAbout extends ConsumerStatefulWidget {
  const ProfileAbout({super.key});

  @override
  ConsumerState<ProfileAbout> createState() => _ProfileAboutState();
}

final style = TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black);

class _ProfileAboutState extends ConsumerState<ProfileAbout> {
  bool _deleting = false;

  Future<void> _confirmDeleteAccount() async {
    final email = ref.read(userEmailProvider) ?? '';
    final passwordController = TextEditingController();
    final emailController = TextEditingController(text: email);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This permanently deactivates your account. This action cannot be undone.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Confirm email'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final ok = await AccountDeletionService.deleteAccountWithBody(
      confirmEmail: emailController.text.trim(),
      password: passwordController.text,
    );
    if (!mounted) return;
    setState(() => _deleting = false);

    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignUp()),
        (_) => false,
      );
    } else {
      Toasty.showtoast('Account deletion failed. Check your password and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color3,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Education", style: style),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => EducationDetails())));
                        },
                        child: Icon(
                          Icons.add,
                          size: 32,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Working",
                        style: style,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => WorkDetails())));
                        },
                        child: Icon(
                          Icons.add,
                          size: 32,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Social Links",
                        style: style,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => SocialLink())));
                        },
                        child: Icon(
                          Icons.add,
                          size: 32,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            vGap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _deleting ? null : _confirmDeleteAccount,
                  icon: _deleting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_forever, color: Colors.red),
                  label: Text(
                    _deleting ? 'Deleting...' : 'Delete Account',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
            vGap(20),
          ],
        ),
      ),
    );
  }
}
