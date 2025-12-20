import 'package:flutter_riverpod/flutter_riverpod.dart';

class SharedContact {
  final String id;
  final String name;
  final String phone;
  final bool isActive;
  final DateTime? lastSharedAt;

  SharedContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isActive = false,
    this.lastSharedAt,
  });
}

class ShareLocationState {
  final bool isSharing;
  final List<SharedContact> contacts;
  final String? shareLink;
  final bool isLoading;

  ShareLocationState({
    this.isSharing = false,
    this.contacts = const [],
    this.shareLink,
    this.isLoading = false,
  });

  ShareLocationState copyWith({
    bool? isSharing,
    List<SharedContact>? contacts,
    String? shareLink,
    bool? isLoading,
  }) {
    return ShareLocationState(
      isSharing: isSharing ?? this.isSharing,
      contacts: contacts ?? this.contacts,
      shareLink: shareLink ?? this.shareLink,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ShareLocationNotifier extends Notifier<ShareLocationState> {
  @override
  ShareLocationState build() {
    _loadContacts();
    return ShareLocationState();
  }

  Future<void> _loadContacts() async {
    // Contacts simulés
    state = state.copyWith(
      contacts: [
        SharedContact(
          id: '1',
          name: 'Marie Dupont',
          phone: '+594 694 12 34 56',
          isActive: false,
        ),
        SharedContact(
          id: '2',
          name: 'Jean Martin',
          phone: '+594 694 78 90 12',
          isActive: false,
        ),
      ],
    );
  }

  Future<String> startSharing() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    final link = 'https://koogwe.app/share/${DateTime.now().millisecondsSinceEpoch}';
    
    state = state.copyWith(
      isSharing: true,
      shareLink: link,
      isLoading: false,
    );
    
    return link;
  }

  Future<void> stopSharing() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));
    
    state = state.copyWith(
      isSharing: false,
      shareLink: null,
      isLoading: false,
    );
  }

  Future<bool> shareWithContact(String contactId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 400));
    
    final contacts = state.contacts.map((contact) {
      if (contact.id == contactId) {
        return SharedContact(
          id: contact.id,
          name: contact.name,
          phone: contact.phone,
          isActive: true,
          lastSharedAt: DateTime.now(),
        );
      }
      return contact;
    }).toList();
    
    state = state.copyWith(
      contacts: contacts,
      isLoading: false,
    );
    
    return true;
  }

  Future<void> removeContact(String contactId) async {
    state = state.copyWith(
      contacts: state.contacts.where((c) => c.id != contactId).toList(),
    );
  }
}

final shareLocationProvider = NotifierProvider<ShareLocationNotifier, ShareLocationState>(
  ShareLocationNotifier.new,
);

