import 'package:bio/components/global.dart';
import 'package:bio/components/section.dart';
import 'package:bio/components/text.dart';
import 'package:bio/components/text_style.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FSectionTitle(icon: 'assets/icons/user-round.svg', text: strings.aboutTitle),
        FCard(
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FText(
                strings.aboutLead,
                style: FTextStyle(fontWeight: FontWeight.w600),
              ),
              for (final paragraph in strings.aboutItems)
                FText(paragraph, style: FTextStyle(color: Global.secondaryColor)),
            ],
          ),
        ),
      ],
    );
  }
}
