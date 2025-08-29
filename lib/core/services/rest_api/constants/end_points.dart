// ignore_for_file: constant_identifier_names, non_constant_identifier_names

abstract class EndPoints {
  //##########  Base Url  ##########
  static const String baseUrl = "http://94.72.98.154/renva/public";
  //auth//
  static const String register = "/api/v1/register";
  static const String login = "/api/v1/login";
  static const String verifyOtp = "/api/v1/verify-otp";
  static const String resendOtp = "/api/v1/resend-otp";
  static const String updateProfile = "/api/v1/update";
  static const String getProfile = "/api/v1/profile";
  static const String delete_profile = "/api/v1/profiles";
  static String deleteProfile(dynamic userId) => "/api/v1/users/delete/$userId";
  static const String forgetPassword = "/api/v1/forget_password";
  static const String resetPassword = "/api/v1/reset_password";
  static const String logout = "/api/v1/logout";
  static const String refresh_fcm_token = "/api/v1/refresh";
  //profile//
  static const String notifications = "/api/v1/notifications";
  static const String settings = "/api/v1/settings";
  static const String privacy = "/api/v1/privacy";
  static const String contacts = "/api/v1/contacts";
  static const String faq = "/api/v1/faq";
  static const String addresses = "/api/v1/addresses";

  static const String service_sub_categories = "/api/v1/sub_categories";
  static const String top_categories = "/api/v1/top_categories";
  static const String provider_categories = "/api/v1/provider_categories";
  static const String join_as_provider = "/api/v1/join_as_provider";
  static const String updateProvider = "/api/v1/provider/update";
  static const String providerReviews = "/api/v1/provider_reviews";
  //order//customers
  static const String new_order = "/api/v1/orders";
  static const String customerOrders = "/api/v1/customer/orders";
  static const String cancel_order_reasons = "/api/v1/order_cancel_reasons";
  static const String cancel_order = "/api/v1/orders/cancel";
  static const String delete_order = "/api/v1/orders";
  static String deleteOrder(String orderId) => "$delete_order/$orderId";
  static const String customer_review = "/api/v1/orders/customer/review";

  ///provider order list and other related :D
  static const String orders_by_status = "/api/v1/orders_by_status";
  static const String providerOrders = "/api/v1/provider_orders";
  static const String provider_complete_order = "/api/v1/orders/provider/end";
  static const String provider_cancel_order = "/api/v1/orders/provider/cancel";
  static const String show_provider_offer = "/api/v1/offers";

  //offer
  static const String new_offer = "/api/v1/offers";
  static const String show_offers = "/api/v1/order/offers";
  static String getOrderOffers(String orderId) => "$show_offers/$orderId";
  static const String accept_offer = "/api/v1/offers/accept";
  static const String decline_offer = "/api/v1/offers/decline";
  static const String offers = "/api/v1/offers";
  static const String cancel_offer = "/api/v1/offers/cancel";
  static String cancelOffer(String offerId) => "$cancel_offer/$offerId";
  static const String delete_offer = "/api/v1/offers";
  static String deleteOffer(String offerId) => "$delete_offer/$offerId";
}
