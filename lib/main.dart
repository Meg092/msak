import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mask_bar/pages/mask_bar_crop/mask_bar_crop_binding.dart';
import 'package:mask_bar/pages/mask_bar_crop/mask_bar_crop_view.dart';
import 'package:mask_bar/pages/mask_bar_edit/mask_bar_edit_binding.dart';
import 'package:mask_bar/pages/mask_bar_edit/mask_bar_edit_view.dart';
import 'package:mask_bar/pages/mask_bar_history/mask_bar_history_binding.dart';
import 'package:mask_bar/pages/mask_bar_history/mask_bar_history_view.dart';
import 'package:mask_bar/pages/mask_bar_home/mask_bar_home_binding.dart';
import 'package:mask_bar/pages/mask_bar_home/mask_bar_home_view.dart';
import 'package:mask_bar/pages/mask_bar_masking/mask_bar_masking_binding.dart';
import 'package:mask_bar/pages/mask_bar_masking/mask_bar_masking_view.dart';
import 'package:mask_bar/pages/mask_bar_record/mask_bar_record_binding.dart';
import 'package:mask_bar/pages/mask_bar_record/mask_bar_record_view.dart';
import 'package:mask_bar/pages/mask_bar_stitch/mask_bar_stitch_binding.dart';
import 'package:mask_bar/pages/mask_bar_stitch/mask_bar_stitch_view.dart';
import 'package:mask_bar/db_mask_bar/index.dart';

Color primaryColor = const Color(0xFF007AFF);
Color bgColor = const Color(0xFFF5F5F5);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Get.putAsync(() => MaskBarDatabase().init());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          getPages: Miss,
          initialRoute: '/mask_bar_home',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: bgColor,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              surface: const Color(0xFFFFFFFF),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF0F0F0F),
              ),
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(size: 22, color: Color(0xFF0F0F0F)),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              selectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              unselectedLabelStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Color(0xFFC9743B),
              unselectedItemColor: Color(0xFF292929),
              elevation: 0,
              backgroundColor: Color(0xFFFFFFFF),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
            dividerTheme: DividerThemeData(
              thickness: 1,
              color: Colors.grey[200],
            ),
          ),
        );
      },
    );
  }
}
List<GetPage<dynamic>> Miss = [
  GetPage(
    name: '/mask_bar_home',
    page: () => const MaskBarHomePage(),
    binding: MaskBarHomeBinding(),
  ),
  GetPage(
    name: '/mask_bar_stitch',
    page: () => const MaskBarStitchPage(),
    binding: MaskBarStitchBinding(),
  ),
  GetPage(
    name: '/mask_bar_crop',
    page: () => const MaskBarCropPage(),
    binding: MaskBarCropBinding(),
  ),
  GetPage(
    name: '/mask_bar_edit',
    page: () => const MaskBarEditPage(),
    binding: MaskBarEditBinding(),
  ),
  GetPage(
    name: '/mask_bar_history',
    page: () => const MaskBarHistoryPage(),
    binding: MaskBarHistoryBinding(),
  ),
  GetPage(
    name: '/mask_bar_masking',
    page: () => const MaskBarMaskingView(),
    binding: MaskBarMaskingBinding(),
  ),
  GetPage(
    name: '/mask_bar_record',
    page: () => const MaskBarRecordPage(),
    binding: MaskBarRecordBinding(),
  ),
];