import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/openai/openai_config.dart';
import 'package:koogwe/core/providers/locale_provider.dart';

final _chatProvider = NotifierProvider<_ChatNotifier, List<_Msg>>(_ChatNotifier.new);

class ChatbotScreen extends ConsumerWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final msgs = ref.watch(_chatProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Support & Chatbot')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              itemCount: msgs.length,
              itemBuilder: (context, i) {
                final m = msgs[i];
                final align = m.me ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                final bubbleColor = m.me
                    ? KoogweColors.primary
                    : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface);
                final textColor = m.me ? Colors.white : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary);
                return Column(
                  crossAxisAlignment: align,
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(KoogweSpacing.lg),
                      constraints: const BoxConstraints(maxWidth: 520),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(m.me ? 16 : 4),
                          bottomRight: Radius.circular(m.me ? 4 : 16),
                        ),
                        border: Border.all(color: m.me ? Colors.transparent : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder)),
                      ),
                      child: Text(m.text, style: GoogleFonts.inter(color: textColor)),
                    ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'Écrivez votre message...'),
                      onSubmitted: (_) => _send(context, ref, controller),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => _send(context, ref, controller),
                    icon: const Icon(Icons.send, color: Colors.white),
                    label: const Text('Envoyer', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _send(BuildContext context, WidgetRef ref, TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return;
    controller.clear();
    ref.read(_chatProvider.notifier).send(text);
  }
}

class _Msg {
  final bool me;
  final String text;
  _Msg(this.me, this.text);
}

class _ChatNotifier extends Notifier<List<_Msg>> {
  final _svc = KoogweChatService();
  @override
  List<_Msg> build() => [];

  Future<void> send(String text) async {
    state = [...state, _Msg(true, text)];
    final locale = ref.read(localeProvider);
    final reply = await _svc.chat(
      text,
      country: locale.countryCode,
      language: locale.locale.languageCode,
      role: 'passenger',
    );
    state = [...state, _Msg(false, reply)];
  }
}
