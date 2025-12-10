import 'package:esx/core/constants/text_styles.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("Welcome to ESX", style: ESXTextStyles.heading),
        Text("Find, Bid & Win Electronics", style: ESXTextStyles.subtitle),
      ],
    );
  }
}
