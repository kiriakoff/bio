import 'package:bio/components/global.dart';
import 'package:bio/components/section.dart';
import 'package:bio/components/text.dart';
import 'package:bio/components/text_style.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class NowSection extends StatelessWidget {
  const NowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FSectionTitle(icon: 'assets/icons/briefcase.svg', text: strings.nowTitle),
        FCard(
          child: Column(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (period, title, description) in strings.now)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: FText(
                        period,
                        style: FTextStyle(
                          fontFamily: 'Source Code Pro',
                          fontSize: 13,
                          color: Global.tertiaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        spacing: 3,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FText(title, style: FTextStyle(fontWeight: FontWeight.w600)),
                          FText(
                            description,
                            style: FTextStyle(fontSize: 15, color: Global.secondaryColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
