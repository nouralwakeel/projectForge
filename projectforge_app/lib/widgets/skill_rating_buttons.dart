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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final double buttonSize = (availableWidth / 5 - 4).clamp(24.0, 32.0);
          final double fontSize = buttonSize < 28 ? 11 : 13;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final rating = index + 1;
              final isSelected = rating == value;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: SizedBox(
                  width: buttonSize,
                  height: buttonSize,
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
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
