import 'package:flutter/material.dart';

import '../core/errors.dart';
import '../models/patient_profile.dart';
import '../services/profile_service.dart';
import '../theme/app_dimensions.dart';
import '../theme/ui_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/app_field.dart';
import '../widgets/app_section_header.dart';
import '../widgets/app_status_banner.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyNumberController = TextEditingController();
  String _gender = 'Male';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _phoneController.dispose();
    _bloodController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _emergencyNameController.dispose();
    _emergencyNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _service.getProfile();
      if (profile != null && mounted) _fill(profile);
    } catch (_) {
      // Keep form empty if the profile doesn't exist yet.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fill(PatientProfile p) {
    _ageController.text = p.age == 0 ? '' : p.age.toString();
    if (const ['Male', 'Female', 'Other'].contains(p.gender)) _gender = p.gender;
    _phoneController.text = p.phoneNumber;
    _bloodController.text = p.bloodGroup;
    _conditionsController.text = p.existingConditions;
    _medicationsController.text = p.medications;
    _allergiesController.text = p.allergies;
    _emergencyNameController.text = p.emergencyContactName;
    _emergencyNumberController.text = p.emergencyContactNumber;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    try {
      await _service.saveProfile(
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        gender: _gender,
        phoneNumber: _phoneController.text.trim(),
        bloodGroup: _bloodController.text.trim(),
        existingConditions: _conditionsController.text.trim(),
        medications: _medicationsController.text.trim(),
        allergies: _allergiesController.text.trim(),
        emergencyContactName: _emergencyNameController.text.trim(),
        emergencyContactNumber: _emergencyNumberController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: ${friendlyError(e)}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.inputScreenBg,
      appBar: AppBar(title: const Text('Patient Profile')),
      body: _loading
          ? Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: context.primary,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              physics: const BouncingScrollPhysics(),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppDimensions.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AppSectionHeader(
                          title: 'Personal Details',
                          subtitle: 'Used to personalize your care guidance',
                          icon: Icons.person_outline_rounded,
                        ),
                        AppTextField(
                          controller: _ageController,
                          label: 'Age',
                          icon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.isEmpty) return null;
                            final age = int.tryParse(t);
                            if (age == null || age <= 0 || age > 120) {
                              return 'Enter a valid age (1–120)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        AppDropdownField<String>(
                          value: _gender,
                          items: const ['Male', 'Female', 'Other'],
                          label: 'Gender',
                          icon: Icons.wc_rounded,
                          onChanged: (v) =>
                              setState(() => _gender = v ?? 'Male'),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _phoneController,
                          label: 'Phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _bloodController,
                          label: 'Blood group',
                          icon: Icons.bloodtype_outlined,
                        ),
                        const SizedBox(height: 26),
                        const AppSectionHeader(
                          title: 'Medical Information',
                          subtitle: 'Anything relevant for your check-ups',
                          icon: Icons.medical_information_outlined,
                        ),
                        AppTextField(
                          controller: _conditionsController,
                          label: 'Existing conditions',
                          icon: Icons.medical_information_outlined,
                          minLines: 1,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _medicationsController,
                          label: 'Medications',
                          icon: Icons.medication_outlined,
                          minLines: 1,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _allergiesController,
                          label: 'Allergies',
                          icon: Icons.warning_amber_rounded,
                          minLines: 1,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 26),
                        const AppSectionHeader(
                          title: 'Emergency Contact',
                          subtitle: 'Shown on high-risk results',
                          icon: Icons.emergency_rounded,
                        ),
                        AppTextField(
                          controller: _emergencyNameController,
                          label: 'Contact name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          controller: _emergencyNumberController,
                          label: 'Contact number',
                          icon: Icons.call_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        const AppStatusBanner(
                          tone: AppStatusTone.warning,
                          message:
                              'Your emergency contact is shown when a symptom '
                              'check flags an urgent or emergency risk.',
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: _saving ? 'Saving…' : 'Save Profile',
                          icon: Icons.save_rounded,
                          loading: _saving,
                          onPressed: _saving ? null : _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}