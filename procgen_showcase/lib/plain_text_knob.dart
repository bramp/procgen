import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:storybook_flutter/storybook_flutter.dart';

extension KnobsBuilderExt on KnobsBuilder {
  String plainText({
    // So much hackiery
    required BuildContext context,

    /// The label is not displayed, but used to uniquely identify the knob.
    required String label,
    required String text,
  }) {
    final oldValue = addKnob<String>(
      Knob(
        label: label,
        knobValue: PlainTextKnobValue(text),
      ),
    );

    // The text  itself is never changed by the knob, instead new values of text
    // may be passed in. However, the storybook framework doesn't check if its
    // changed, so we manually do a update.
    if (oldValue != text) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<KnobsNotifier>().update(label, text);
      });
    }
    return text;
  }
}

class PlainTextKnobValue extends KnobValue<String> {
  PlainTextKnobValue(String text) : super(value: text);

  @override
  Widget build({
    required String label,
    required String? description,
    required bool enabled,
    required bool nullable,
  }) {
    return ListTile(
      subtitle: SelectableText(value, style: GoogleFonts.sourceCodePro()),
    );
  }
}
