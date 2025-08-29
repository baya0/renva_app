import 'package:flutter/material.dart';
import 'package:renva0/core/style/repo.dart';

class AppStyle {
  static ThemeData get theme {
    return ThemeData(
      primaryColor: StyleRepo.deepBlue,
      scaffoldBackgroundColor: StyleRepo.softWhite,
      colorScheme: ColorScheme.light(
        primary: StyleRepo.deepBlue,
        secondary: StyleRepo.forestGreen,
        surface: StyleRepo.softWhite,
        error: Colors.red,
      ),

      // Text themes
      textTheme: TextTheme(
        titleSmall: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: StyleRepo.softWhite,
        ),
        titleMedium: TextStyle(fontSize: 20, color: StyleRepo.black, fontWeight: FontWeight.w700),
        headlineSmall: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: StyleRepo.black,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: StyleRepo.black,
        ),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: StyleRepo.softWhite,
        ),
        labelSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: StyleRepo.grey,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: StyleRepo.grey,
        ),
        labelMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: StyleRepo.black,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: StyleRepo.softWhite,

        // Text style for input text
        labelStyle: const TextStyle(color: StyleRepo.softGrey, fontSize: 16),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StyleRepo.softGrey, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StyleRepo.softGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: StyleRepo.deepBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),

        // Content padding
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),

        // Icon constraints
        prefixIconConstraints: const BoxConstraints(minWidth: 60, minHeight: 48),
        suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),

        // Icon theme for prefix/suffix icons
        iconColor: Colors.grey[600],
        prefixIconColor: Colors.grey[600],
        suffixIconColor: Colors.grey[600],
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StyleRepo.deepBlue,
          foregroundColor: StyleRepo.softWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // Navigation bar theme
      navigationBarTheme: NavigationBarThemeData(
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: StyleRepo.forestGreen);
          }
          return const IconThemeData(color: StyleRepo.softGreen);
        }),
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: StyleRepo.deepBlue,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: StyleRepo.softWhite),
        titleTextStyle: TextStyle(
          color: StyleRepo.softWhite,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  get textTheme => null;

  static Widget buildFormField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? Function(String?)? validator,
    required String hintText,
    required Widget prefixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: theme.textTheme.labelSmall,
            prefixIcon: Container(
              width: 60,
              height: 48,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFE0E0E0), width: 1)),
              ),
              child: prefixIcon,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
