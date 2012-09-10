#define YOUCRYPT_ERROR_DOMAIN @"com.youcrypt"

///////////////////////////////////////
//              ERRORS
///////////////////////////////////////
#define YOUCRYPT_DECRYPT_INCORRECT_PASSWD 1
#define YC_ERRORDOMAIN             @"com.youcrypt.errors"
#define YC_PASSPHRASEERROR_NOTIFICATION @"__yc_passphraseerror_notification"


///////////////////////////////////////
//          PATH STRINGS
///////////////////////////////////////

#define YOUCRYPT_XMLCONFIG_FILENAME             @".youcryptfs.xml"
#define ENCRYPTED_DIRECTORY_EXTENSION           @"yc"
#define ENCRYPTION_TEMPORARY_FOLDER             @".encrypted.yc"

///////////////////////////////////////
//          PREFERENCE KEYS
///////////////////////////////////////
// string prefrence keys
#define YC_DROPBOXLOCATION  @"yc.dropboxfolderlocation"
#define YC_BOXLOCATION      @"yc.boxfolderlocation"
#define YC_USERREALNAME     @"yc.userrealname"
#define YC_USEREMAIL        @"yc.email"
#define YC_GMAILUSERNAME    @"yc.gmailusername"
// bool preference keys
#define YC_ENCRYPTFILENAMES @"yc.encryptfilenames"
#define YC_STARTONBOOT      @"yc.startonboot"
#define YC_BOXSTATUS        @"yc.boxstatus"
#define YC_ANONYMOUSSTATISTICS @"yc.anonymousstatistics"
#define YC_IDLETIME         @"yc.idletime"
#define YC_KEYCHAIN_SERVICENAME @"com.Youcrypt"


///////////////////////////////////////
//      NOTIFICATION NAMES
///////////////////////////////////////
#define YC_KEYOPS_NOTIFICATION     @"yc.keyops.notification"
#define YC_SERVEROPS_NOTIFICATION  @"yc.serverops.notification"

///////////////////////////////////////
//          COMMANDS
///////////////////////////////////////
#define UMOUNT_CMD              @"/sbin/umount"
#define MOUNT_CMD               @"/sbin/mount"


///////////////////////////////////////
//          SECRETS
///////////////////////////////////////
#define MIXPANEL_TOKEN @"b01b99df347adcb20353ba2a4cb6faf4" // avr@nouvou.com's token


///////////////////////////////////////
//          SERVER CONFIG
///////////////////////////////////////
#define API_BASE_URL "https://youcrypt.herokuapp.com/"
//#define API_BASE_URL "http://localhost:3000/"
// This string should match the one set on the server (config/initializers/youcrypt_constants.rb)
#define YC_USER_AGENT "YouCrypt_User_Agent_e4946cc8f61edaaccb8239c3f1b43cc3"
#define YC_YOUCRYPT_DOWNLOADLOCATION @"http://youcrypt.com/alpha/download"

///////////////////////////////////////
//          MAILGUN CONFIG
///////////////////////////////////////
#define YC_MAILGUN_API_KEY @"api:key-4xtch32ho6y6lcnv9euv8668kws42d49"
#define YC_MAILGUN_URL     @"https://api.mailgun.net/v2/cloudclear.mailgun.org/messages"


