import 'package:bio/components/divider.dart';
import 'package:bio/components/global.dart';
import 'package:bio/components/link.dart';
import 'package:bio/components/text.dart';
import 'package:bio/components/text_style.dart';
import 'package:bio/content.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return Column(
      spacing: 16,
      children: [
        FDivider(),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            FLink(
              'github.com/${Content.githubHandle}',
              Content.githubUrl,
              style: FTextStyle(color: Global.secondaryColor),
            ),
            FText('·', style: FTextStyle(color: Global.faintColor)),
            FLink(
              strings.email,
              'mailto:${strings.email}',
              style: FTextStyle(color: Global.secondaryColor),
            ),
            FText('·', style: FTextStyle(color: Global.faintColor)),
            FText(strings.city, style: FTextStyle(color: Global.tertiaryColor)),
          ],
        ),
        FText(
          strings.copyright(Content.currentYear),
          style: FTextStyle(fontSize: 13, color: Global.faintColor),
        ),
      ],
    );
  }
}
