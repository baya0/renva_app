// ignore_for_file: constant_identifier_names, non_constant_identifier_names

abstract class EndPoints {
  //##########  Base Url  ##########
  static const String baseUrl =
      'https://b4f84ebd-016e-4fed-9492-9e3bd664d12b.mock.pstmn.io/';

  //Auth
  static const login = "login";
  static const register = "register";
  //vertification
  static const verifyPhone = "verify-phone";
  static const requestVerificationCode = "request-verification-code";
  static const completeProfile = "complete-profile";
  // Content
  static const categories = "categories";
  static const products = "products";
  static product(int id) => "products/$id";
}
