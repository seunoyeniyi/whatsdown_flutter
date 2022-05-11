// ignore_for_file: non_constant_identifier_names

class Site {
  static String NAME = "WhatsDown";
  static String PROTOCOL = "https";
  static String DOMAIN =
      "whatsdown.in"; //"192.168.43.11"; // "192.168.43.223"; //"10.0.2.2"; //
  static String ADDRESS = PROTOCOL + "://" + DOMAIN + "/";
  static String TOKEN_KEY =
      "OyO3muQ98b1uEHzQVg4X4trpFcrx3SxFFZIWXHAOz6HWZBUoLe";
  static String TOKEN_KEY_APPEND = "&token_key=" + TOKEN_KEY;
  static String INFO = ADDRESS + "wp-json/skye-api/v1/site-info/";
  static String CART = ADDRESS + "wp-json/skye-api/v1/cart/";
  static String ADD_TO_CART = ADDRESS + "wp-json/skye-api/v1/add-to-cart/";
  static String PRODUCTS = ADDRESS + "wp-json/skye-api/v1/products/";
  static String SIMPLE_PRODUCTS =
      ADDRESS + "wp-json/skye-api/v1/simple-products/";
  static String PRODUCT = ADDRESS + "wp-json/skye-api/v1/product/";
  static String PRODUCT_VARIATION =
      ADDRESS + "wp-json/skye-api/v1/product-variation/";
  static String LOGIN = ADDRESS + "wp-json/skye-api/v1/authenticate";
  static String REGISTER = ADDRESS + "wp-json/skye-api/v1/register/";
  static String USER = ADDRESS + "wp-json/skye-api/v1/user-info/";
  static String UPDATE_USER = ADDRESS + "wp-json/skye-api/v1/update-user-info/";
  static String UPDATE_SHIPPING =
      ADDRESS + "wp-json/skye-api/v1/update-user-shipping-address/";
  static String UPDATE_CART_SHIPPING =
      ADDRESS + "wp-json/skye-api/v1/update-cart-shipping/";
  static String CREATE_ORDER =
      ADDRESS + "wp-json/skye-api/v2/create-order/"; //v2
  static String UPDATE_COUPON =
      ADDRESS + "wp-json/skye-api/v1/update-cart-coupon/";
  static String CHANGE_CART_SHIPPING =
      ADDRESS + "wp-json/skye-api/v1/change-cart-shipping-method/";
  static String ORDERS = ADDRESS + "wp-json/skye-api/v1/orders/";
  static String ORDER = ADDRESS + "wp-json/skye-api/v1/order/";
  static String UPDATE_ORDER = ADDRESS + "wp-json/skye-api/v1/update-order/";
  static String CATEGORIES = ADDRESS + "wp-json/skye-api/v1/categories/";
  static String ATTRIBUTES = ADDRESS + "wp-json/skye-api/v1/attributes/";
  static String TAGS = ADDRESS + "wp-json/skye-api/v1/tags/";
  static String ADD_TO_WISH_LIST =
      ADDRESS + "wp-json/skye-api/v1/add-to-wishlist/";
  static String REMOVE_FROM_WISH_LIST =
      ADDRESS + "wp-json/skye-api/v1/remove-from-wishlist/";
  static String WISH_LIST = ADDRESS + "wp-json/skye-api/v1/wishlists/";
  static String BANNERS = ADDRESS + "wp-json/skye-api/v1/banners/";
  static String COMPLETE_ORDER_PAGE = ADDRESS + "app-complete-order/";
  static String APPLY_REWARD =
      ADDRESS + "wp-json/skye-api/v1/apply-cart-reward/";
  static String SAVE_DEVICE = ADDRESS + "wp-json/skye-api/v1/save-user-device/";
  static String ADD_DEVICE = ADDRESS + "wp-json/skye-api/v1/add-device/";
  static String SEARCH = ADDRESS + "wp-json/skye-api/v1/search/";
  static String ADD_REVIEW = ADDRESS + "wp-json/skye-api/v1/add-review/";

  static String CURRENCY = "₹";
  static String payment_method_title(String slug) {
    String title = "";
    switch (slug) {
      case "cod":
        title = "Cash On Delivery";
        break;
      case "bacs":
        title = "Direct Bank Transfer";
        break;
      case "cheque":
        title = "Check Payments";
        break;
      case "paypal":
        title = "Paypal";
        break;
      case "stripe":
        title = "Stripe";
        break;
      case "stripe_cc":
        title = "Credit Cards";
        break;
      case "accept-kiosk":
        title = "Aman";
        break;
      case "accept-wallet":
        title = "Mobile Wallet";
        break;
      case "accept-sympl":
        title = "Sympl";
        break;
      case "accept-online":
        title = "Visa/MasterCard";
        break;
      case "myfatoorah_v2":
        title = "Credit Card";
        break;
      default:
        title = "No Payment method";
        break;
    }
    return title;
  }
}
