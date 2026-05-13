import 'package:flutter/material.dart';

class SkillSlider extends StatelessWidget {
  final String skillName;
  final int proficiency;
  final ValueChanged<double> onChanged;

  const SkillSlider({
    super.key,
    required this.skillName,
    required this.proficiency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(skillName),
      subtitle: Slider(
        value: proficiency.toDouble(),
        min: 0,
        max: 5,
        divisions: 5,
        label: proficiency == 0 ? 'غير محدد' : proficiency.toString(),
        onChanged: onChanged,
      ),
      trailing: proficiency > 0
          ? CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '$proficiency',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : const SizedBox(width: 32),
    );
  }
}
