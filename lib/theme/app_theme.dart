static ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: primaryDark,
    onPrimary: onPrimaryDark,
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    background: backgroundDark,
    onBackground: textPrimaryDark,
    error: errorDark,
    onError: onPrimaryDark,
    secondary: accentDark,
    onSecondary: onPrimaryDark,
    shadow: const Color(0x66000000),
    scrim: const Color(0x80000000),
    inverseSurface: surfaceLight,
    onInverseSurface: onSurfaceLight,
    inversePrimary: primaryLight,
  ),
  scaffoldBackgroundColor: backgroundDark,
  cardColor: surfaceDark,
  dividerColor: dividerDark,
  appBarTheme: AppBarTheme(
    backgroundColor: backgroundDark,
    foregroundColor: textPrimaryDark,
    elevation: 0,
    scrolledUnderElevation: 2,
    shadowColor: const Color(0x66000000),
    surfaceTintColor: Colors.transparent,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
      letterSpacing: 0.15,
    ),
    iconTheme: IconThemeData(color: textPrimaryDark),
    actionsIconTheme: IconThemeData(color: textPrimaryDark),
  ),
  cardTheme: CardTheme(
    color: surfaceDark,
    elevation: 2,
    shadowColor: const Color(0x66000000),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: const EdgeInsets.all(8.0),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: surfaceDark,
    selectedItemColor: primaryDark,
    unselectedItemColor: textSecondaryDark,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
    selectedLabelStyle: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    unselectedLabelStyle: GoogleFonts.roboto(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryDark,
    foregroundColor: onPrimaryDark,
    elevation: 6,
    focusElevation: 8,
    hoverElevation: 8,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: onPrimaryDark,
      backgroundColor: primaryDark,
      elevation: 2,
      shadowColor: const Color(0x66000000),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      side: BorderSide(color: dividerDark, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.25,
      ),
    ),
  ),
  textTheme: _buildDarkTextTheme(),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: surfaceDark,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: dividerDark, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: dividerDark, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: primaryDark, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorDark, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorDark, width: 2),
    ),
    labelStyle: GoogleFonts.roboto(
      color: textSecondaryDark,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    hintStyle: GoogleFonts.roboto(
      color: textSecondaryDark.withOpacity(0.6),
      fontSize: 16,
      fontWeight: FontWeight.w400,
    ),
    errorStyle: GoogleFonts.roboto(
      color: errorDark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return primaryDark;
      return textSecondaryDark;
    }),
    trackColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) {
        return primaryDark.withOpacity(0.5);
      }
      return dividerDark;
    }),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return primaryDark;
      return Colors.transparent;
    }),
    checkColor: MaterialStateProperty.all(onPrimaryDark),
    side: BorderSide(color: dividerDark, width: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
  ),
  radioTheme: RadioThemeData(
    fillColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.selected)) return primaryDark;
      return textSecondaryDark;
    }),
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: primaryDark,
    linearTrackColor: dividerDark,
    circularTrackColor: dividerDark,
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryDark,
    thumbColor: primaryDark,
    overlayColor: primaryDark.withOpacity(0.2),
    inactiveTrackColor: dividerDark,
    valueIndicatorColor: primaryDark,
    valueIndicatorTextStyle: GoogleFonts.robotoMono(
      color: onPrimaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: primaryDark,
    unselectedLabelColor: textSecondaryDark,
    indicatorColor: primaryDark,
    indicatorSize: TabBarIndicatorSize.label,
    labelStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    unselectedLabelStyle: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
    ),
  ),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: textPrimaryDark.withOpacity(0.9),
      borderRadius: BorderRadius.circular(4),
    ),
    textStyle: GoogleFonts.roboto(
      color: backgroundDark,
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: textPrimaryDark,
    contentTextStyle: GoogleFonts.roboto(
      color: backgroundDark,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    actionTextColor: accentDark,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
    elevation: 6,
  ),
  dialogTheme: DialogTheme(
    backgroundColor: surfaceDark,
    titleTextStyle: GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: textPrimaryDark,
    ),
    contentTextStyle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: textSecondaryDark,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
  ),
); // 👈 Final closing bracket for ThemeData
