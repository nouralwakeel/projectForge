import 'package:flutter/material.dart';
import '../../models/project_model.dart';

class SkillChip extends StatelessWidget {
  final ProjectSkillModel skill;

  const SkillChip({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text('${(skill.weight * 100).round()}', style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
      label: Text(skill.name),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
