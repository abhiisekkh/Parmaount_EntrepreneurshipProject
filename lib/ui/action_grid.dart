import 'package:flutter/material.dart';

class ActionGridItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? iconColor;

  ActionGridItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.iconColor,
  });
}

class ActionGrid extends StatelessWidget {
  final List<ActionGridItem> items;
  final int crossAxisCount;
  final double spacing;

  const ActionGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 2,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Card(
          color: item.color ?? Theme.of(context).cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: item.onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, size: 40, color: item.iconColor ?? Theme.of(context).primaryColor),
                const SizedBox(height: 10),
                Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
