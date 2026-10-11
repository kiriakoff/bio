import 'package:bio/components/global.dart';
import 'package:bio/components/section.dart';
import 'package:bio/components/text.dart';
import 'package:bio/components/text_style.dart';
import 'package:bio/state/app_state.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class StackSection extends StatelessWidget {
  const StackSection({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppState>().strings;
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FSectionTitle(icon: 'assets/icons/terminal.svg', text: strings.stackTitle),
        FCard(
          child: Column(
            spacing: 14,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (label, items) in strings.stack)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 175,
                      child: FText(
                        label,
                        style: FTextStyle(
                          fontWeight: FontWeight.w600,
                          color: Global.secondaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final (index, item) in items.indexed) ...[
                            if (index > 0)
                              FText('·', style: FTextStyle(color: Global.faintColor)),
                            FText(item, style: FTextStyle(fontWeight: FontWeight.w500)),
                          ],
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
