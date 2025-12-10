import 'package:esx/core/constants/colors.dart';
import 'package:esx/core/constants/text_styles.dart';
import 'package:esx/core/widgets/app_header.dart';
import 'package:esx/features/bids/view/live_bids_page.dart';
import 'package:esx/features/bids/view/my_bids_page.dart';
import 'package:flutter/material.dart';

class BidsTabPage extends StatelessWidget {
  const BidsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: AppHeader(),
          bottom: const TabBar(
            labelColor: ESXColors.blackColor,
            indicatorColor: ESXColors.blackColor,
            unselectedLabelColor: ESXColors.greyColor,
            tabs: [
              Tab(text: 'Won Products'),
              Tab(text: 'Live Bids'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyBidsPage(),
            LiveBidsPage(),
          ],
        ),
      ),
    );
  }
}
