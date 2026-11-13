/// A lightweight user representation used throughout the UI.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;

  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return 'Shopper';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return email.isEmpty ? 'S' : email[0].toUpperCase();
    }
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
