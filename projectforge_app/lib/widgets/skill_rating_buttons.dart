import 'package:flutter/material.dart';

class SkillRatingButtons extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final Color inactiveBorderColor;
  final Color activeBgColor;
  final Color activeTextColor;

  const SkillRatingButtons({
    super.key,
    required this.value,
    required this.onChanged,
    required this.inactiveBorderColor,
    required this.activeBgColor,
    required this.activeTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final rating = index + 1;
          final isSelected = rating <= value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              width: 32,
              height: 32,
              child: Material(
                color: isSelected ? activeBgColor : Colors.transparent,
                shape: CircleBorder(
                  side: isSelected
                      ? BorderSide.none
                      : BorderSide(color: inactiveBorderColor, width: 2),
                ),
                elevation: isSelected ? 3 : 0,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onChanged(rating),
                  child: Center(
                    child: Text(
                      '$rating',
                      style: TextStyle(
                        color: isSelected
                            ? activeTextColor
                            : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
