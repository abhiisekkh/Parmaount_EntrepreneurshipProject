import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? imageUrl;
  final Widget? trailing;

  const ProfileHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.imageUrl,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
          backgroundImage: imageUrl != null ? AssetImage(imageUrl!) : null,
          child: imageUrl == null
              ? Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor)
              : null,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $name',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
