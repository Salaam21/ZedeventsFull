import 'package:event_app/app/configs/theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:event_app/app/resources/constant/named_routes.dart';
import 'package:event_app/ui/pages/create_event_page.dart';
import 'package:event_app/ui/pages/detail_page.dart';
import 'package:event_app/ui/pages/home_page.dart';
import 'package:event_app/ui/pages/interest_selection_page.dart';
import 'package:event_app/ui/pages/login_page.dart';
import 'package:event_app/ui/pages/my_events_page.dart';
import 'package:event_app/ui/pages/profile_page.dart';
import 'package:event_app/ui/pages/search_page.dart';
import 'package:event_app/ui/pages/settings_page.dart';
import 'package:event_app/ui/pages/signup_page.dart';
import 'package:event_app/ui/pages/ticket_page.dart';
import 'package:flutter/material.dart';

void main() {
  // Prevent GoogleFonts from fetching fonts at runtime (device may be offline).
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZedEvents - Event Marketplace',
      debugShowCheckedModeBanner: false,
      theme: Themes.lightTheme,
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case NamedRoutes.homeScreen:
            return MaterialPageRoute(builder: (context) => const HomePage());
          case NamedRoutes.detailScreen:
            return MaterialPageRoute(
              builder: (_) => const DetailPage(),
              settings: settings,
            );
          case NamedRoutes.ticketScreen:
            return MaterialPageRoute(
              builder: (context) => const TicketPage(),
              settings: settings,
            );
          case NamedRoutes.searchScreen:
            return MaterialPageRoute(builder: (context) => const SearchPage());
          case NamedRoutes.loginScreen:
            return MaterialPageRoute(builder: (context) => const LoginPage());
          case NamedRoutes.signupScreen:
            return MaterialPageRoute(builder: (context) => const SignupPage());
          case NamedRoutes.interestSelectionScreen:
            return MaterialPageRoute(
                builder: (context) => const InterestSelectionPage());
          case NamedRoutes.profileScreen:
            return MaterialPageRoute(builder: (context) => const ProfilePage());
          case NamedRoutes.createEventScreen:
            return MaterialPageRoute(
                builder: (context) => const CreateEventPage());
          case NamedRoutes.myEventsScreen:
            return MaterialPageRoute(
                builder: (context) => const MyEventsPage());
          case NamedRoutes.settingsScreen:
            return MaterialPageRoute(
                builder: (context) => const SettingsPage());
          default:
            return MaterialPageRoute(builder: (context) => const HomePage());
        }
      },
    );
  }
}
