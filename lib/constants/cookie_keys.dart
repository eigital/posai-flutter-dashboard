// Same key strings as eatos-live-dashboard/src/lib/cookieKeys.ts

const String cookieKeyToken = 'token';
const String cookieKeyStoreId = 'storeId';
const String cookieKeyMainStoreId = 'mainStoreId';
const String cookieKeyMerchantId = 'merchantId';
const String cookieKeyEmployeeId = 'employeeId';
const String cookieKeyEmployeeName = 'employeeName';
const String cookieKeyHas2FA = 'has2FA';
const String cookieKeyRoleName = 'roleName';
const String cookieKeySuperAdmin = 'superAdminPage';
const String cookieKeyLoggedAccount = 'loggedAccount';
const String cookieKeyEmployeeMobile = 'employeeMobile';
const String cookieKeyCurrency = 'currency';
const String cookieKeyCurrencyCode = 'currencyCode';

String permissionCookieKey(String name) => 'permissionName$name';
