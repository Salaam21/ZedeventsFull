enum EventCategory {
  music,
  sports,
  motorShows,
  conferences,
  parties,
  cultural,
  football,
  concerts,
  festivals,
  exhibitions,
  workshops,
  other,
}

extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.music:
        return 'Music';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.motorShows:
        return 'Motor Shows';
      case EventCategory.conferences:
        return 'Conferences';
      case EventCategory.parties:
        return 'Parties';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.football:
        return 'Football';
      case EventCategory.concerts:
        return 'Concerts';
      case EventCategory.festivals:
        return 'Festivals';
      case EventCategory.exhibitions:
        return 'Exhibitions';
      case EventCategory.workshops:
        return 'Workshops';
      case EventCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case EventCategory.music:
        return '🎵';
      case EventCategory.sports:
        return '⚽';
      case EventCategory.motorShows:
        return '🏎️';
      case EventCategory.conferences:
        return '💼';
      case EventCategory.parties:
        return '🎉';
      case EventCategory.cultural:
        return '🎭';
      case EventCategory.football:
        return '⚽';
      case EventCategory.concerts:
        return '🎤';
      case EventCategory.festivals:
        return '🎪';
      case EventCategory.exhibitions:
        return '🖼️';
      case EventCategory.workshops:
        return '📚';
      case EventCategory.other:
        return '📌';
    }
  }

  static EventCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case 'music':
        return EventCategory.music;
      case 'sports':
        return EventCategory.sports;
      case 'motorshows':
      case 'motor shows':
        return EventCategory.motorShows;
      case 'conferences':
        return EventCategory.conferences;
      case 'parties':
        return EventCategory.parties;
      case 'cultural':
        return EventCategory.cultural;
      case 'football':
        return EventCategory.football;
      case 'concerts':
        return EventCategory.concerts;
      case 'festivals':
        return EventCategory.festivals;
      case 'exhibitions':
        return EventCategory.exhibitions;
      case 'workshops':
        return EventCategory.workshops;
      default:
        return EventCategory.other;
    }
  }
}



