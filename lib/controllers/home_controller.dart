import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart';
import 'package:skyewooapp/handlers/user_session.dart';
import 'package:skyewooapp/models/banner.dart';
import 'package:skyewooapp/site.dart';

class HomeController extends GetxController {
  var userSession = UserSession().obs;

  //loading
  var bigBannerLoading = true.obs;
  var slideBannerLoading = true.obs;
  var thinBannerLoading = true.obs;
  var gridBannerLoading = true.obs;
  var carouselBannerLoading = true.obs;

  //availabilities
  var bigBannerEnabled = true.obs;
  var slideBannerEnabled = true.obs;
  var thinBannerEnabled = true.obs;
  var gridBannerEnabled = true.obs;
  var carouselBannerEnabled = true.obs;

  //lists
  var bigBanners = <Banner>[].obs;
  var slideBanners = <Banner>[].obs;
  var thinBanners = <Banner>[].obs;
  var gridBanners = <Banner>[].obs;
  var carouselBanners = <Banner>[].obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    await userSession.value.init();
    fetchBanner("big");
    fetchBanner("slide");
    fetchBanner("thin");
    fetchBanner("grid");
    fetchBanner("carousel");
  }

  void fetchBanner(String type) async {
    var connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      return;
    }

    List<Banner> returnedBanner = [];

    try {
      if (type == "big") {
        bigBannerLoading.value = true;
      }
      if (type == "slide") {
        slideBannerLoading.value = true;
      }
      if (type == "thin") {
        thinBannerLoading.value = true;
      }
      if (type == "grid") {
        gridBannerLoading.value = true;
      }
      if (type == "carousel") {
        carouselBannerLoading.value = true;
      }

      //fetch
      String url = Site.BANNERS + "?type=" + type + Site.TOKEN_KEY_APPEND;

      Response response = await get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        Map<String, dynamic> json = jsonDecode(response.body);

        List<Map<String, dynamic>> banners = List.from(json["results"]);

        if (int.parse(json["count"].toString()) > 0) {
          returnedBanner.clear();

          for (var banner in banners) {
            returnedBanner.add(Banner(
              image: banner["image"].toString(),
              title: banner["title"].toString(),
              description: banner["description"].toString(),
              onClickTo: banner["on_click_to"].toString(),
              category: banner["category"].toString(),
              url: banner["url"].toString(),
            ));
          }
        }
      }
    } finally {
      if (type == "big") {
        bigBanners.value = returnedBanner;
        bigBannerLoading.value = false;
        bigBannerEnabled.value = bigBanners.isNotEmpty;
      }
      if (type == "slide") {
        slideBanners.value = returnedBanner;
        slideBannerLoading.value = false;
        slideBannerEnabled.value = slideBanners.isNotEmpty;
      }
      if (type == "thin") {
        thinBanners.value = returnedBanner;
        thinBannerLoading.value = false;
        thinBannerEnabled.value = thinBanners.isNotEmpty;
      }
      if (type == "grid") {
        gridBanners.value = returnedBanner;
        gridBannerLoading.value = false;
        gridBannerEnabled.value = gridBanners.isNotEmpty;
      }
      if (type == "carousel") {
        carouselBanners.value = returnedBanner;
        carouselBannerLoading.value = false;
        carouselBannerEnabled.value = carouselBanners.isNotEmpty;
      }
    }
  }
}
