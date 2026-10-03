class AppRoutes {
  AppRoutes._();

  // Auth Routes
  static const String splashRoute = '/splash-screen';
  static const String roleSelectionRoute = '/role-selection';
  static const String ownerloginRoute = '/owner-login';
  static const String trainerloginRoute = '/trainer-login';
  static const String clientloginRoute = '/client-login';
  static const String forgetPasswordRoute = '/forget-password';
  static const String purchaseMemberShipRoute = '/purchase-membership';
  static const String gymDetailedRoute = '/gym-detailed';
  static const String qrScreenRoute = '/qr-screen';

  // Owner Routes
  static const String ownerDashboardRoute = '/owner-dashboard';
  static const String ownerMemberRoute = '/owner-member';
  static const String ownerTrainerRoute = '/owner-trainer';
  static const String memberShipRoute = '/member-ship';
  static const String ownerNotificationRoute = '/onwer-notification';
  static const String ownerProfileRoute = '/owner-profile';
  static const String ownerEditProfileRoute = '/owner-profile/edit';
  static const String addMemberRoute = '/add-member';
  static const String addTrainerRoute = '/add-trainer';

  // Trainer Routes
  static const String trainerDashboardRoute = '/trainer-dashboard';
  static const String trainerClientRoute = '/trainer-client';
  static const String trainerProfileRoute = '/trainer-profile';
  static const String trainerScheduleRoute = '/trainer-schedule';
  static const String trainerProgressRoute = '/trainer-progress';

  // Member Routes

  static const String memberDashboardRoute = '/member-dashboard';
  static const String memberHomeRoute = memberDashboardRoute;
  static const String memberWorkoutRoute = '/member-dashboard/workout';
  static const String memberProgressRoute = '/member-dashboard/progress';
  static const String memberNutritionRoute = '/member-dashboard/nutrition';
  static const String memberProfileRoute = '/member-dashboard/profile';

  static const String memberHomeName = 'memberHome';
  static const String memberWorkoutName = 'memberWorkout';
  static const String memberProgressName = 'memberProgress';
  static const String memberNutritionName = 'memberNutrition';
  static const String memberProfileName = 'memberProfile';
}
