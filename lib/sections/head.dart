import 'package:bio/components/button.dart';
import 'package:bio/components/global.dart';
import 'package:bio/components/surface.dart';
import 'package:bio/components/text.dart';
import 'package:bio/components/text_style.dart';
import 'package:bio/content.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HeadSection extends StatelessWidget {
  const HeadSection({super.key});

  static const double photoSize = 176;

  void openGithub(PointerDownEvent event) {
    launchUrl(Uri.parse(Content.githubUrl), mode: LaunchMode.externalApplication);
  }

  void openTg(PointerDownEvent event) {
    launchUrl(Uri.parse(Content.contactTg), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return Column(
      spacing: 14,
      children: [
        FSurface(
          round: true,
          // Единственная видимая тема-зависимая краска фото — тонкое кольцо:
          // в каскаде оно возникало рывком не в такт волне, поэтому фронт
          // волны синхронизирован геометрически.
          stagger: false,
          width: photoSize,
          height: photoSize,
          constraints: BoxConstraints.tight(Size(photoSize, photoSize)),
          child: Image.asset(
            'assets/images/me.png',
            width: photoSize,
            height: photoSize,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 4),
        FText(strings.name, heading: 1, textAlign: TextAlign.center),
        FText(
          '${strings.role} · ${strings.company}',
          textAlign: TextAlign.center,
          style: FTextStyle(fontFamily: 'Source Code Pro', fontSize: 15),
        ),
        FText(
          '${strings.city} · ${strings.ageLabel}',
          textAlign: TextAlign.center,
          style: FTextStyle(color: Global.tertiaryColor),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            FButton(
              label: strings.githubButton,
              icon: 'assets/icons/github.svg',
              onPressed: openGithub,
            ),
            FButton(
              label: strings.tgButton,
              icon: 'assets/icons/telegram.svg',
              onPressed: openTg,
            ),
          ],
        ),
      ],
    );
  }
}
