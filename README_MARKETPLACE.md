# ZedEvents - Event Marketplace Platform

A comprehensive Flutter event marketplace application where users can discover, create, and sell tickets for various events.

## 🎯 Project Overview

ZedEvents is a full-featured event marketplace similar to Facebook Marketplace, but specifically designed for events. Users can post events, sell tickets, and discover events based on their interests.

## ✨ Key Features

### 1. **Event Discovery & Browsing**
- **Home Page** with categorized event listings
- **Category Filtering** - Filter events by:
  - 🎵 Music
  - ⚽ Sports
  - 🏎️ Motor Shows
  - 💼 Conferences
  - 🎉 Parties
  - 🎭 Cultural Events
  - 🎤 Concerts
  - 🎪 Festivals
  - 🖼️ Exhibitions
  - 📚 Workshops
  - And more...
- **Search Functionality** - Search events by name, location, or tags
- **Featured Events** highlighting

### 2. **User Interest System**
- Interest selection during onboarding
- Personalized event recommendations based on user interests
- Ability to update interests anytime from profile

### 3. **Event Creation & Management**
- **Create Events** with comprehensive details:
  - Event title and description
  - Category selection
  - Date, time, and location
  - Online/Offline event support
  - Event capacity
  - Custom event images
- **Multiple Ticket Types**:
  - Free tickets
  - Regular tickets
  - VIP tickets
  - Early Bird tickets
  - Custom pricing for each type
- **My Events Page** - Manage your posted events
- Edit and delete event capabilities

### 4. **Ticket Marketplace**
- Multiple ticket tiers per event
- Real-time ticket availability
- Price range display
- Sold out indicators
- Ticket quantity tracking

### 5. **Event Details**
- Complete event information display
- Organizer profile with ratings
- Ticket options breakdown
- Attendee count
- Location/online meeting details
- Event time and duration

### 6. **User Authentication**
- Login/Signup pages
- User profile management
- Verified organizer badges
- Profile customization

### 7. **Profile & Settings**
- User statistics (events attended, saved, posted)
- Interest management
- Event history
- Saved events
- Settings and preferences

## 📱 App Structure

### Pages
```
lib/ui/pages/
├── home_page.dart              # Main dashboard with event listings
├── search_page.dart            # Search and filter events
├── detail_page.dart            # Event details and ticket info
├── ticket_page.dart            # Ticket display page
├── create_event_page.dart      # Create new events
├── my_events_page.dart         # Manage user's events
├── profile_page.dart           # User profile
├── login_page.dart             # User login
├── signup_page.dart            # User registration
└── interest_selection_page.dart # Select user interests
```

### Data Models
```
lib/data/
├── event_model.dart            # Event data structure
├── user_model.dart             # User data structure
├── organizer_model.dart        # Event organizer data
├── ticket_model.dart           # Ticket type data
└── category_enum.dart          # Event categories
```

### Services
```
lib/services/
└── api_service.dart            # API service layer (ready for backend integration)
```

## 🎨 Key UI Components

- **Category Filter Chips** - Horizontal scrollable category selector
- **Event Cards** - Beautiful event display cards
- **Navigation Bar** - Bottom navigation with 4 main sections
- **Search Interface** - Real-time search with category filtering
- **Ticket Options Display** - Clear pricing and availability

## 💾 Data Structure

### Event Model
```dart
- id, title, image, date, location, description
- category (EventCategory enum)
- organizer (OrganizerModel)
- tickets (List<TicketModel>)
- capacity, attendees
- startTime, endTime
- isOnline, meetingUrl
- tags, isFeatured
- createdAt
```

### User Model
```dart
- id, name, email, phone
- profileImage, bio
- interests (List<EventCategory>)
- location, dateJoined
- savedEvents, postedEvents, attendedEvents
- isOrganizer
```

### Ticket Model
```dart
- id, type (TicketType enum)
- price, totalAvailable, sold
- currency
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=2.17.5 <3.0.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. Clone the repository
```bash
cd event-app-master
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^3.0.1
  flutter_bloc: ^8.1.1
```

## 🔧 Backend Integration

The app includes a complete API service layer (`lib/services/api_service.dart`) that's ready for backend integration. Currently using mock data for demonstration.

### API Service Methods
- User authentication (login, signup, logout)
- Event CRUD operations
- Search and filtering
- Interest management
- Ticket booking
- Event saving/unsaving

### To Connect to Backend:
1. Update `ApiService.baseUrl` with your API endpoint
2. Implement actual HTTP requests in each API method
3. Handle authentication tokens
4. Add error handling and loading states

## 📊 Sample Data

The app includes 12 diverse sample events in `assets/json/data_event.json`:
- Music festivals
- Sports events (NBA, Football)
- Tech conferences
- Motor shows
- Cultural events
- Workshops
- Parties
- And more...

## 🎯 User Flows

### New User Flow
1. Open app → See login/signup screen
2. Sign up → Select interests
3. View personalized home feed
4. Browse/search events
5. View event details and book tickets

### Event Organizer Flow
1. Login as verified organizer
2. Navigate to Create Event
3. Fill in event details
4. Add ticket types and pricing
5. Publish event
6. Manage events from "My Events" page

## 🔐 Features Ready for Production

✅ Complete UI/UX implementation
✅ State management with BLoC
✅ Data models and structures
✅ API service layer structure
✅ Category filtering
✅ Search functionality
✅ User interest system
✅ Event creation and management
✅ Multiple ticket types
✅ Navigation and routing

## 🚧 Future Enhancements

- [ ] Connect to real backend API
- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Event reviews and ratings
- [ ] Social sharing
- [ ] Maps integration for event locations
- [ ] QR code ticket generation
- [ ] Chat with organizers
- [ ] Event recommendations algorithm
- [ ] Analytics dashboard for organizers

## 🎨 Design Highlights

- Modern, clean UI design
- Smooth animations and transitions
- Responsive layouts
- Category-based color coding
- Intuitive navigation
- Material Design principles
- Custom widgets and components

## 📱 Screenshots

The app includes:
- Beautiful event cards with images
- Category chips for filtering
- Detailed event pages with organizer info
- Ticket pricing breakdown
- User profile with statistics
- Search interface
- Event creation forms

## 🤝 Contributing

This is a marketplace platform ready for:
- Backend integration
- Payment processing
- Additional features
- UI improvements
- Testing

## 📄 License

See LICENSE file for details.

## 👨‍💻 Development Notes

### State Management
- Using BLoC pattern for event loading
- Local state management for UI components
- Singleton ApiService for data operations

### Navigation
- Named routes for all pages
- Arguments passing for event details
- Bottom navigation bar for main sections

### Code Organization
- Separation of concerns (UI, Data, Services)
- Reusable widgets
- Type-safe models
- Enum-based categories

## 📞 Support

For issues, questions, or contributions, please refer to the project repository.

---

**Built with ❤️ using Flutter**

*Ready to transform the event ticketing experience!*



