import 'package:bio/components/text.dart';
import 'package:bio/components/text_style.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class FLink extends StatelessWidget {
  final String text;
  final String url;
  final FTextStyle? style;

  const FLink(this.text, this.url, {super.key, this.style});

  void open() {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: open,
        child: FText(
          text,
          style: FTextStyle(
            fontSize: style?.fontSize,
            fontWeight: style?.fontWeight,
            fontFamily: style?.fontFamily,
            heading: style?.heading,
            color: style?.color,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
