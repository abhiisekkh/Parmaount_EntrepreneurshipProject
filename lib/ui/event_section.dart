import 'package:flutter/material.dart';

class EventItem {
  final String title;
  final String date;
  final String description;
  final IconData icon;
  final Color? color;

  EventItem({
    required this.title,
    required this.date,
    required this.description,
    this.icon = Icons.event,
    this.color,
  });
}

class EventSection extends StatelessWidget {
  final List<EventItem> events;
  final String? sectionTitle;

  const EventSection({
    super.key,
    required this.events,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionTitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              sectionTitle!,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ...events.map((event) => Card(
              color: event.color ?? Colors.blueGrey.shade50,
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(event.icon, size: 32, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.date,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            event.description,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
