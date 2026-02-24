import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MaterialListTile extends StatelessWidget {
  final String name;
  final num quantity;
  final String unit;
  final num? price;
  final String? projectName;
  final VoidCallback onTap;

  const MaterialListTile({
    super.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.projectName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(LucideIcons.package)),
        title: Text(
          name,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mennyiség: $quantity $unit'),
            if (price != null) Text('Ár: ${_formatPrice(price!.toDouble())} HUF'),
            if (projectName != null)
              Text(
                'Projekt: $projectName',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(priceStr[i]);
    }

    return buffer.toString();
  }
}
