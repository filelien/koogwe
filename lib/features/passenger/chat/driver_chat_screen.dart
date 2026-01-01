import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider pour gérer les messages de chat
final driverChatProvider = NotifierProvider<DriverChatNotifier, DriverChatState>(() {
  return DriverChatNotifier();
});

class DriverChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  DriverChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  DriverChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return DriverChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isFromDriver;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isFromDriver = false,
    this.isRead = true,
  });
}

class DriverChatNotifier extends Notifier<DriverChatState> {
  final _supabase = Supabase.instance.client;
  String? _rideId;
  String? _driverId;

  @override
  DriverChatState build() {
    return DriverChatState();
  }

  void setRideContext(String rideId, String driverId) {
    _rideId = rideId;
    _driverId = driverId;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_rideId == null) return;

    state = state.copyWith(isLoading: true);
    try {
      // Charger les messages depuis Supabase
      // Note: Vous devrez créer une table 'chat_messages' dans Supabase
      final response = await _supabase
          .from('chat_messages')
          .select()
          .eq('ride_id', _rideId!)
          .order('created_at', ascending: true);

      final messages = (response as List)
          .map((json) => ChatMessage(
                id: json['id'].toString(),
                text: json['message'],
                timestamp: DateTime.parse(json['created_at']),
                isFromDriver: json['sender_id'] == _driverId,
                isRead: json['is_read'] ?? false,
              ))
          .toList();

      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      // Si la table n'existe pas, utiliser des messages simulés
      state = state.copyWith(
        messages: _getMockMessages(),
        isLoading: false,
      );
    }
  }

  List<ChatMessage> _getMockMessages() {
    return [
      ChatMessage(
        id: '1',
        text: 'Bonjour ! J\'arrive dans 5 minutes.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isFromDriver: true,
      ),
      ChatMessage(
        id: '2',
        text: 'Parfait, merci !',
        timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
        isFromDriver: false,
      ),
    ];
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      isFromDriver: false,
    );

    state = state.copyWith(
      messages: [...state.messages, message],
    );

    try {
      // Envoyer le message à Supabase
      if (_rideId != null) {
        await _supabase.from('chat_messages').insert({
          'ride_id': _rideId!,
          'message': text,
          'sender_id': _supabase.auth.currentUser?.id,
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        });
      }

      // Simuler une réponse du chauffeur après 2 secondes
      Future.delayed(const Duration(seconds: 2), () {
        final driverReply = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Message reçu, je vous informe dès mon arrivée.',
          timestamp: DateTime.now(),
          isFromDriver: true,
        );
        state = state.copyWith(
          messages: [...state.messages, driverReply],
        );
      });
    } catch (e) {
      debugPrint('Erreur envoi message: $e');
    }
  }
}

class DriverChatScreen extends ConsumerStatefulWidget {
  final String? rideId;
  final String? driverId;
  final String? driverName;
  final String? driverAvatar;

  const DriverChatScreen({
    super.key,
    this.rideId,
    this.driverId,
    this.driverName,
    this.driverAvatar,
  });

  @override
  ConsumerState<DriverChatScreen> createState() => _DriverChatScreenState();
}

class _DriverChatScreenState extends ConsumerState<DriverChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.rideId != null && widget.driverId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(driverChatProvider.notifier).setRideContext(
              widget.rideId!,
              widget.driverId!,
            );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    ref.read(driverChatProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(driverChatProvider);
    final driverName = widget.driverName ?? 'Chauffeur';

    return Scaffold(
      backgroundColor: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: KoogweColors.primary.withValues(alpha: 0.2),
              child: widget.driverAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        widget.driverAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: KoogweColors.primary,
                        ),
                      ),
                    )
                  : Icon(Icons.person, color: KoogweColors.primary),
            ),
            const SizedBox(width: KoogweSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? KoogweColors.darkTextPrimary 
                          : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    'En ligne',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: KoogweColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {
              // TODO: Appeler le chauffeur
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 64,
                              color: isDark 
                                  ? KoogweColors.darkTextTertiary 
                                  : KoogweColors.lightTextTertiary,
                            ),
                            const SizedBox(height: KoogweSpacing.md),
                            Text(
                              'Aucun message',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: isDark 
                                    ? KoogweColors.darkTextSecondary 
                                    : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(KoogweSpacing.lg),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          final isDriver = message.isFromDriver;
                          final showTime = index == 0 ||
                              (index > 0 &&
                                  message.timestamp.difference(
                                        chatState.messages[index - 1].timestamp,
                                      ).inMinutes >
                                      5);

                          return Column(
                            crossAxisAlignment: isDriver
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.end,
                            children: [
                              if (showTime)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: KoogweSpacing.sm,
                                  ),
                                  child: Center(
                                    child: GlassCard(
                                      borderRadius: KoogweRadius.fullRadius,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: KoogweSpacing.md,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          DateFormat('HH:mm').format(message.timestamp),
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: isDark
                                                ? KoogweColors.darkTextTertiary
                                                : KoogweColors.lightTextTertiary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              Row(
                                mainAxisAlignment: isDriver
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (isDriver) ...[
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: KoogweColors.primary,
                                      child: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: KoogweSpacing.sm),
                                  ],
                                  Flexible(
                                    child: GlassCard(
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(16),
                                        topRight: const Radius.circular(16),
                                        bottomLeft: Radius.circular(isDriver ? 4 : 16),
                                        bottomRight: Radius.circular(isDriver ? 16 : 4),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(KoogweSpacing.md),
                                        child: Text(
                                          message.text,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: isDark
                                                ? KoogweColors.darkTextPrimary
                                                : KoogweColors.lightTextPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isDriver) ...[
                                    const SizedBox(width: KoogweSpacing.sm),
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: KoogweColors.secondary,
                                      child: Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ],
                              ).animate().fadeIn().slideX(
                                    begin: isDriver ? -0.2 : 0.2,
                                    end: 0,
                                  ),
                              const SizedBox(height: KoogweSpacing.xs),
                            ],
                          );
                        },
                      ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        borderRadius: KoogweRadius.fullRadius,
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Tapez votre message...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: KoogweSpacing.md,
                              vertical: KoogweSpacing.sm,
                            ),
                            hintStyle: GoogleFonts.inter(
                              color: isDark
                                  ? KoogweColors.darkTextTertiary
                                  : KoogweColors.lightTextTertiary,
                            ),
                          ),
                          style: GoogleFonts.inter(
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: KoogweSpacing.md),
                    Container(
                      decoration: BoxDecoration(
                        color: KoogweColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

