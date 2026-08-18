import 'package:get/get.dart';
import 'package:handy/modules/auth/bindings/auth_binding.dart';
import 'package:handy/modules/auth/views/login_view.dart';
import 'package:handy/modules/auth/views/register_view.dart';
import 'package:handy/modules/auth/views/forgot_password_view.dart';
import 'package:handy/modules/auth/views/otp_view.dart';
import 'package:handy/modules/auth/views/update_password_view.dart';
import 'package:handy/modules/bible/bindings/bible_binding.dart';
import 'package:handy/modules/bible/views/bible_view.dart';
import 'package:handy/modules/bible_chapters/views/bible_chapters_view.dart';
import 'package:handy/modules/bible_chapters/bindings/bible_chapter_binding.dart';
import 'package:handy/modules/bible_verses/bindings/bible_verses_binding.dart';
import 'package:handy/modules/bible_verses/views/bible_verses_view.dart';
import 'package:handy/modules/community/bindings/community_binding.dart';
import 'package:handy/modules/community/views/community_view.dart';
import 'package:handy/modules/devotionals/bindings/devotionals_binding.dart';
import 'package:handy/modules/devotionals/views/devotionals_view.dart';
import 'package:handy/modules/devotionals_details/bindings/devotionals_details_binding.dart';
import 'package:handy/modules/devotionals_details/views/devotionals_details_view.dart';
import 'package:handy/modules/donate/bindings/donate_binding.dart';
import 'package:handy/modules/event_details/bindings/event_details_binding.dart';
import 'package:handy/modules/event_details/views/event_details_view.dart';
import 'package:handy/modules/events/bindings/events_binding.dart';
import 'package:handy/modules/events/views/events_view.dart';
import 'package:handy/modules/events_history/bindings/events_history_binding.dart';
import 'package:handy/modules/events_history/views/events_history_view.dart';
import 'package:handy/modules/events_history_details/bindings/events_history_details_binding.dart';
import 'package:handy/modules/events_history_details/views/events_history_details_view.dart';
import 'package:handy/modules/give/bindings/give_binding.dart';
import 'package:handy/modules/give/views/give_view.dart';
import 'package:handy/modules/history_and_core_values/bindings/history_and_core_values_binding.dart';
import 'package:handy/modules/history_and_core_values/views/history_and_core_values_view.dart';
import 'package:handy/modules/more/bindings/more_binding.dart';
import 'package:handy/modules/more/views/more_view.dart';
import 'package:handy/modules/notifications/bindings/notifications_binding.dart';
import 'package:handy/modules/notifications/views/notifications_view.dart';
import 'package:handy/modules/prayer_wall/bindings/prayer_wall_binding.dart';
import 'package:handy/modules/prayer_wall/views/prayer_wall_view.dart';
import 'package:handy/modules/sermon_details/bindings/sermon_details_binding.dart';
import 'package:handy/modules/sermon_details/views/sermon_details_view.dart';
import 'package:handy/modules/sermons/bindings/sermons_binding.dart';
import 'package:handy/modules/sermons/views/sermons_view.dart';
import 'package:handy/modules/watch_live/bindings/watch_live_binding.dart';
import 'package:handy/modules/watch_live/views/watch_live_view.dart';
import 'package:handy/modules/donate/views/donate_view.dart';
import '../../core/middleware/auth_middleware.dart';
import '../../core/widgets/screens/no_internet_screen.dart';
import '../../modules/bottom_nab_bar/bindings/bottom_nab_bar_binding.dart';
import '../../modules/bottom_nab_bar/views/bottom_nab_bar_view.dart';
import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/search/bindings/search_binding.dart';
import '../../modules/search/views/search_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';

/// ===================== APP ROUTES =====================
/// All named route constants. Use these instead of hardcoding route strings.
abstract class AppRoutes {
  // ignore: constant_identifier_names
  static const String SPLASH = '/splash';
  // ignore: constant_identifier_names
  static const String LOGIN = '/login';
  // ignore: constant_identifier_names
  static const String REGISTER = '/register';
  // ignore: constant_identifier_names
  static const String FORGOT_PASSWORD = '/forgot-password';
  // ignore: constant_identifier_names
  static const String OTP_VERIFICATION = '/otp-verification';
  // ignore: constant_identifier_names
  static const String UPDATE_PASSWORD = '/update-password';
  // ignore: constant_identifier_names
  static const String HOME = '/home';
  // ignore: constant_identifier_names
  static const String PROFILE = '/profile';
  // ignore: constant_identifier_names
  static const String BOTTOM_NAV_BAR = '/bottom-nav-bar';
  // ignore: constant_identifier_names
  static const String SEARCH = '/search';
  // ignore: constant_identifier_names
  static const String SETTINGS = '/settings';
  // ignore: constant_identifier_names
  static const String NO_INTERNET = '/no-internet';
  // ignore: constant_identifier_names
  static const String LOCK = '/lock';
  // ignore: constant_identifier_names
  static const String SERMONS = '/sermons';
  // ignore: constant_identifier_names
  static const String GIVE = '/give';
  // ignore: constant_identifier_names
  static const String EVENTS = '/events';
  // ignore: constant_identifier_names
  static const String MORE = '/more';
  // ignore: constant_identifier_names
  static const String SERMON_DETAILS = '/sermon-details';
  // ignore: constant_identifier_names
  static const String EVENT_DETAILS = '/event-details';
  // ignore: constant_identifier_names
  static const String NOTIFICATION = '/notification';
  // ignore: constant_identifier_names
  static const String BIBLE = '/bible';
  // ignore: constant_identifier_names
  static const String BIBLE_CHAPTERS = '/bible-chapters';
  // ignore: constant_identifier_names
  static const String BIBLE_VERSES = '/bible-verses';
  // ignore: constant_identifier_names
  static const String COMMUNITY = '/community';
  // ignore: constant_identifier_names
  static const String DEVOTIONALS = '/devotionals';
  // ignore: constant_identifier_names
  static const String DEVOTIONALS_DETAILS = '/devotionals-details';
  // ignore: constant_identifier_names
  static const String PRAYER_WALL = '/prayer-wall';
  // ignore: constant_identifier_names
  static const String WATCH_LIVE = '/watch-live';
  // ignore: constant_identifier_names
  static const String HISTORY_AND_CORE_VALUES = '/history-and-core-values';
  // ignore: constant_identifier_names
  static const String DONATE = '/donate';
  // ignore: constant_identifier_names
  static const String EVENTS_HISTORY = '/events-history';
  // ignore: constant_identifier_names
  static const String EVENTS_HISTORY_DETAILS = '/events-history-details';
}

/// ===================== APP PAGES =====================
/// Route-to-page mapping with bindings and middleware.
final List<GetPage> pages = [
  // ─── Public Routes ───
  GetPage(
    name: AppRoutes.SPLASH,
    page: () => const SplashView(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: AppRoutes.LOGIN,
    page: () => const LoginView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.REGISTER,
    page: () => const RegisterView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.FORGOT_PASSWORD,
    page: () => const ForgotPasswordView(),
    binding: AuthBinding(),
  ),
  GetPage(name: AppRoutes.NO_INTERNET, page: () => const NoInternetScreen()),

  // ─── Protected Routes (require authentication) ───
  GetPage(
    name: AppRoutes.BOTTOM_NAV_BAR,
    page: () => const BottomNavBarView(),
    binding: BottomNavBarBinding(),
  ),
  GetPage(
    name: AppRoutes.HOME,
    page: () => const HomeView(),
    binding: HomeBinding(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoutes.PROFILE,
    page: () => const ProfileView(),
    binding: ProfileBinding(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoutes.SEARCH,
    page: () => const SearchView(),
    binding: SearchBinding(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoutes.SETTINGS,
    page: () => const SettingsView(),
    binding: SettingsBinding(),
  ),
  GetPage(
    name: AppRoutes.SERMONS,
    page: () => const SermonsView(),
    binding: SermonsBinding(),
  ),
  GetPage(
    name: AppRoutes.GIVE,
    page: () => const GiveView(),
    binding: GiveBinding(),
  ),
  GetPage(
    name: AppRoutes.EVENTS,
    page: () => const EventsView(),
    binding: EventsBinding(),
  ),
  GetPage(
    name: AppRoutes.MORE,
    page: () => const MoreView(),
    binding: MoreBinding(),
    middlewares: [AuthMiddleware()],
  ),
  GetPage(
    name: AppRoutes.SERMON_DETAILS,
    page: () => const SermondetailsView(),
    binding: SermondetailsBinding(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: AppRoutes.EVENT_DETAILS,
    page: () => const EventDetailsView(),
    binding: EventDetailsBinding(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: AppRoutes.NOTIFICATION,
    page: () => const NotificationView(),
    binding: NotificationsBinding(),
  ),
  GetPage(
    name: AppRoutes.BIBLE,
    page: () => const BibleView(),
    binding: BibleBinding(),
  ),
  GetPage(
    name: AppRoutes.BIBLE_CHAPTERS,
    page: () => const BibleChaptersView(),
    binding: BibleChapterBinding(),
  ),
  GetPage(
    name: AppRoutes.BIBLE_VERSES,
    page: () => const BibleVersesView(),
    binding: BibleVersesBinding(),
  ),
  GetPage(
    name: AppRoutes.COMMUNITY,
    page: () => const CommunityView(),
    binding: CommunityBinding(),
  ),
  GetPage(
    name: AppRoutes.DEVOTIONALS,
    page: () => const DevotionalsView(),
    binding: DevotionalsBinding(),
  ),
  GetPage(
    name: AppRoutes.DEVOTIONALS_DETAILS,
    page: () => DevotionalsDetailsView(),
    binding: DevotionalsDetailsBinding(),
  ),
  GetPage(
    name: AppRoutes.PRAYER_WALL,
    page: () => const PrayerWallView(),
    binding: PrayerWallBinding(),
  ),
  GetPage(
    name: AppRoutes.WATCH_LIVE,
    page: () => const WatchLiveView(),
    binding: WatchLiveBinding(),
  ),
  GetPage(
    name: AppRoutes.HISTORY_AND_CORE_VALUES,
    page: () => const HistoryAndCoreValuesView(),
    binding: HistoryAndCoreValuesBinding(),
  ),
  GetPage(
    name: AppRoutes.DONATE,
    page: () => const DonateView(),
    binding: DonateBinding(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: AppRoutes.OTP_VERIFICATION,
    page: () => const OtpView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.UPDATE_PASSWORD,
    page: () => const UpdatePasswordView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.EVENTS_HISTORY,
    page: () => const EventsHistoryView(),
    binding: EventsHistoryBinding(),
  ),
  GetPage(
    name: AppRoutes.EVENTS_HISTORY_DETAILS,
    page: () => const EventsHistoryDetailsView(),
    binding: EventsHistoryDetailsBinding(),
  ),
];
