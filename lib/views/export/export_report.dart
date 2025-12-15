import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/export_model.dart';
import '../../services/firebase_service.dart';
import '../../theme/design_system.dart';

class ExportReportPage extends StatefulWidget {
  const ExportReportPage({super.key});

  @override
  State<ExportReportPage> createState() => _ExportReportPageState();
}

class _ExportReportPageState extends State<ExportReportPage> {
  late ShareSettings _shareSettings;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _shareSettings = ShareSettings(
      includeSymptoms: true,
      includeMood: true,
      includeInsights: true,
      includeRecommendations: true,
      shareMethod: 'email',
    );
  }

  Future<ExportReport> _generateReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final cycles = await FirebaseService.getCycles(user.uid);
    final symptoms = await FirebaseService.getSymptoms(user.uid);
    final moods = await FirebaseService.getMoodHistory(user.uid);

    final cycleInfo = cycles.isNotEmpty
        ? 'Total Cycles: ${cycles.length}\nAverage Length: ${(cycles.map((c) => (c["cycleLength"] as int?) ?? 28).reduce((a, b) => a + b) / cycles.length).toStringAsFixed(1)} days'
        : 'No cycle data available';

    final symptomsInfo = symptoms.isNotEmpty
        ? 'Total Logs: ${symptoms.length}\nMost Common: ${_getMostCommonSymptom(symptoms)}'
        : 'No symptom data available';

    final moodsInfo = moods.isNotEmpty
        ? 'Total Logs: ${moods.length}\nMost Common: ${_getMostCommonMood(moods)}'
        : 'No mood data available';

    final insightsInfo = '''
• Consistent tracking helps improve predictions
• Your cycle patterns are being analyzed
• Share this report with your healthcare provider for better insights
''';

    final recommendations = '''
• Continue logging symptoms daily for better accuracy
• Track mood changes to identify patterns
• Maintain consistent sleep schedule
• Stay hydrated throughout your cycle
• Exercise regularly, adjusting intensity by phase
''';

    return ExportReport(
      title: 'BloomCycle Health Report',
      generatedDate: DateFormat('MMMM d, yyyy - h:mm a').format(DateTime.now()),
      cycleInfo: cycleInfo,
      symptomsData: symptomsInfo,
      moodData: moodsInfo,
      insightsData: insightsInfo,
      recommendations: recommendations,
    );
  }

  String _getMostCommonSymptom(List<Map<String, dynamic>> symptoms) {
    final symptomMap = <String, int>{};
    for (final symptom in symptoms) {
      final list = (symptom['symptoms'] as List?)?.cast<String>() ?? [];
      for (final s in list) {
        symptomMap[s] = (symptomMap[s] ?? 0) + 1;
      }
    }
    if (symptomMap.isEmpty) return 'None';
    return symptomMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getMostCommonMood(List<Map<String, dynamic>> moods) {
    final moodMap = <String, int>{};
    for (final mood in moods) {
      final moodName = mood['mood'] as String? ?? 'Unknown';
      moodMap[moodName] = (moodMap[moodName] ?? 0) + 1;
    }
    if (moodMap.isEmpty) return 'None';
    return moodMap.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3FA),
      appBar: AppBar(
        title: const Text('Export & Share'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExportOptions(),
            const SizedBox(height: 24),
            _buildShareSettings(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildExportOption(
            'PDF Report',
            'Generate a formatted PDF for your doctor',
            Icons.picture_as_pdf,
            const Color(0xFFFF6B6B),
            () => _handleExport('pdf'),
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            'CSV Export',
            'Export data for spreadsheet analysis',
            Icons.table_chart,
            const Color(0xFF4DABF7),
            () => _handleExport('csv'),
          ),
          const SizedBox(height: 12),
          _buildExportOption(
            'Share Report',
            'Send report via email or messaging',
            Icons.share,
            const Color(0xFF51CF66),
            () => _handleExport('share'),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildShareSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Include in Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxItem('Symptoms Data', _shareSettings.includeSymptoms, (
            value,
          ) {
            setState(() {
              _shareSettings = _shareSettings.copyWith(includeSymptoms: value);
            });
          }),
          const SizedBox(height: 12),
          _buildCheckboxItem('Mood Patterns', _shareSettings.includeMood, (
            value,
          ) {
            setState(() {
              _shareSettings = _shareSettings.copyWith(includeMood: value);
            });
          }),
          const SizedBox(height: 12),
          _buildCheckboxItem(
            'Insights & Analysis',
            _shareSettings.includeInsights,
            (value) {
              setState(() {
                _shareSettings = _shareSettings.copyWith(
                  includeInsights: value,
                );
              });
            },
          ),
          const SizedBox(height: 12),
          _buildCheckboxItem(
            'Health Recommendations',
            _shareSettings.includeRecommendations,
            (value) {
              setState(() {
                _shareSettings = _shareSettings.copyWith(
                  includeRecommendations: value,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (newValue) => onChanged(newValue ?? false),
          activeColor: AppColors.primary,
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reports are for personal health tracking. Share with healthcare providers for medical advice.',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: _isGenerating ? null : () => _handleExport('preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Preview Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleExport(String type) async {
    setState(() => _isGenerating = true);
    try {
      final report = await _generateReport();

      if (!mounted) return;

      if (type == 'preview') {
        _showReportPreview(report);
      } else if (type == 'pdf') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF export feature coming soon!')),
        );
      } else if (type == 'csv') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CSV export feature coming soon!')),
        );
      } else if (type == 'share') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share feature coming soon!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  void _showReportPreview(ExportReport report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Preview'),
        content: SingleChildScrollView(child: Text(report.toPdfFormat())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
