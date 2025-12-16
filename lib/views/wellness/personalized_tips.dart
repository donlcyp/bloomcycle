import 'package:flutter/material.dart';
import '../../theme/design_system.dart';
import '../../theme/responsive_helper.dart';

class PersonalizedTipsPage extends StatefulWidget {
  const PersonalizedTipsPage({super.key});

  @override
  State<PersonalizedTipsPage> createState() => _PersonalizedTipsPageState();
}

class _PersonalizedTipsPageState extends State<PersonalizedTipsPage> {
  String _selectedPhase = 'Menstruation';
  final phases = ['Menstruation', 'Follicular', 'Ovulation', 'Luteal'];

  final phasesTips = {
    'Menstruation': {
      'energy': 'Low energy is normal. Focus on rest and recovery.',
      'exercise': 'Light activities like yoga, walking, or stretching',
      'nutrition': 'Iron-rich foods, dark leafy greens, red meat',
      'hydration': 'Increase water intake to combat dehydration',
      'mood': 'Practice self-compassion and stress management',
      'sleep': 'Aim for 8-9 hours of quality sleep',
    },
    'Follicular': {
      'energy': 'Energy levels rising. Great time for new projects!',
      'exercise': 'High-intensity workouts, strength training',
      'nutrition': 'Light meals, whole grains, lean proteins',
      'hydration': 'Maintain regular hydration (8 glasses daily)',
      'mood': 'Mood improves. Social activities are beneficial',
      'sleep': '7-8 hours of sleep supports recovery',
    },
    'Ovulation': {
      'energy': 'Peak energy and confidence. Maximum productivity!',
      'exercise': 'Intense workouts, competitive sports',
      'nutrition': 'Balanced diet with antioxidants',
      'hydration': 'Stay well-hydrated during peak activity',
      'mood': 'Highest mood and social confidence',
      'sleep': 'May need slightly less sleep (6-7 hours)',
    },
    'Luteal': {
      'energy': 'Energy dips mid-phase. Plan accordingly.',
      'exercise': 'Moderate activities, strength training',
      'nutrition': 'Complex carbs, magnesium-rich foods',
      'hydration': 'Increase water and electrolyte intake',
      'mood': 'Practice stress management and self-care',
      'sleep': 'Aim for 8-9 hours for mood regulation',
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3FA),
      appBar: AppBar(
        title: const Text('Personalized Tips'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: ResponsiveHelper.getHorizontalPadding(context),
          right: ResponsiveHelper.getHorizontalPadding(context),
          top: ResponsiveHelper.getVerticalPadding(context),
          bottom: ResponsiveHelper.getVerticalPadding(context) + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPhaseSelector(),
            SizedBox(
              height: ResponsiveHelper.getSpacing(
                context,
                small: 16,
                medium: 20,
                large: 24,
              ),
            ),
            _buildPhaseDescription(),
            SizedBox(
              height: ResponsiveHelper.getSpacing(
                context,
                small: 16,
                medium: 20,
                large: 24,
              ),
            ),
            _buildTipsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhaseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Cycle Phase',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: EdgeInsets.only(
              right: ResponsiveHelper.getHorizontalPadding(context),
            ),
            child: Row(
              children: phases.map((phase) {
                final isSelected = _selectedPhase == phase;
                final colors = {
                  'Menstruation': const Color(0xFFFF6B6B),
                  'Follicular': const Color(0xFF4DABF7),
                  'Ovulation': const Color(0xFFFFD93D),
                  'Luteal': const Color(0xFF51CF66),
                };
                final color = colors[phase] ?? AppColors.primary;

                return Padding(
                  padding: EdgeInsets.only(
                    right: ResponsiveHelper.getSpacing(
                      context,
                      small: 6,
                      medium: 8,
                      large: 10,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPhase = phase),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.getFontSize(
                          context,
                          small: 12,
                          medium: 14,
                          large: 16,
                        ),
                        vertical: ResponsiveHelper.getSpacing(
                          context,
                          small: 8,
                          medium: 10,
                          large: 10,
                        ),
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color
                            : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: color,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        phase,
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            small: 11,
                            medium: 12,
                            large: 12,
                          ),
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : color,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseDescription() {
    final descriptions = {
      'Menstruation':
          'Days 1-5: Your period. Energy may be lower. Focus on rest and self-care.',
      'Follicular':
          'Days 6-13: Rising estrogen. Energy increases, mood improves. Great for new projects.',
      'Ovulation':
          'Days 14-15: Peak fertility. High energy and confidence. Most fertile days.',
      'Luteal':
          'Days 16-28: Progesterone rises. Energy may dip. Practice self-compassion.',
    };

    final padding = ResponsiveHelper.getHorizontalPadding(context);
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
      padding: EdgeInsets.all(padding),
      child: Text(
        descriptions[_selectedPhase] ?? '',
        style: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(
            context,
            small: 12,
            medium: 14,
            large: 14,
          ),
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTipsGrid() {
    final tips = phasesTips[_selectedPhase] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tips for This Phase',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(
              context,
              small: 16,
              medium: 18,
              large: 18,
            ),
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          height: ResponsiveHelper.getSpacing(
            context,
            small: 10,
            medium: 12,
            large: 12,
          ),
        ),
        ...tips.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(
                context,
                small: 10,
                medium: 12,
                large: 12,
              ),
            ),
            child: _buildTipCard(entry.key, entry.value),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTipCard(String category, String tip) {
    final icons = {
      'energy': Icons.bolt,
      'exercise': Icons.fitness_center,
      'nutrition': Icons.restaurant,
      'hydration': Icons.water_drop,
      'mood': Icons.emoji_emotions,
      'sleep': Icons.bedtime,
    };

    final colors = {
      'energy': const Color(0xFFFFD93D),
      'exercise': const Color(0xFF51CF66),
      'nutrition': const Color(0xFFFF6B6B),
      'hydration': const Color(0xFF4DABF7),
      'mood': const Color(0xFFD946A6),
      'sleep': const Color(0xFF9C27B0),
    };

    final icon = icons[category] ?? Icons.info;
    final color = colors[category] ?? AppColors.primary;
    final padding = ResponsiveHelper.getHorizontalPadding(context);

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
      padding: EdgeInsets.all(padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          SizedBox(
            width: ResponsiveHelper.getSpacing(
              context,
              small: 10,
              medium: 12,
              large: 12,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.replaceFirst(category[0], category[0].toUpperCase()),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 12,
                      medium: 14,
                      large: 14,
                    ),
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(
                  height: ResponsiveHelper.getSpacing(
                    context,
                    small: 3,
                    medium: 4,
                    large: 4,
                  ),
                ),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      small: 11,
                      medium: 13,
                      large: 13,
                    ),
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
