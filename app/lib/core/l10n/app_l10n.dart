import 'package:flutter/material.dart';

/// Simple dual-language helper — English (default) and Irish (Gaeilge).
/// Access via: AppL10n(ref.watch(appLocaleProvider))
class AppL10n {
  final Locale locale;
  const AppL10n(this.locale);

  bool get _ga => locale.languageCode == 'ga';

  // ─── Navigation ─────────────────────────────────────────────────────────────
  String get navHome       => _ga ? 'Baile'           : 'Home';
  String get navHerd       => _ga ? 'Tréad'           : 'Herd';
  String get navHealth     => _ga ? 'Sláinte'         : 'Health';
  String get navMovements  => _ga ? 'Gluaiseachtaí'   : 'Movements';
  String get navScanner    => _ga ? 'Scanóir'         : 'Scanner';

  // ─── Common ──────────────────────────────────────────────────────────────────
  String get save          => _ga ? 'Sábháil'         : 'Save';
  String get cancel        => _ga ? 'Cealaigh'        : 'Cancel';
  String get dismiss       => _ga ? 'Dún'             : 'Dismiss';
  String get next          => _ga ? 'Ar Aghaidh'      : 'Next';
  String get edit          => _ga ? 'Eagar'           : 'Edit';
  String get required_     => _ga ? 'Riachtanach'     : 'Required';

  // ─── Settings ────────────────────────────────────────────────────────────────
  String get settings      => _ga ? 'Socruithe'       : 'Settings';
  String get farmProfile   => _ga ? 'Próifíl Feirme'  : 'Farm Profile';
  String get noFarmSetUp   => _ga ? 'Gan fheirm socraithe' : 'No farm set up';
  String get addNewFarm    => _ga ? 'Feirm Nua a Chur Leis' : 'Add New Farm';
  String get preferences   => _ga ? 'Roghanna'        : 'Preferences';
  String get darkMode      => _ga ? 'Mód Dorcha'      : 'Dark Mode';
  String get units         => _ga ? 'Aonaid'          : 'Units';
  String get language      => _ga ? 'Teanga'          : 'Language';
  String get scanner       => _ga ? 'Scanóir'         : 'Scanner';
  String get about         => _ga ? 'Maidir Leis'     : 'About';
  String get version       => _ga ? 'Leagan'          : 'Version';
  String get privacyPolicy => _ga ? 'Polasaí Príobháideachais' : 'Privacy Policy';

  // ─── BLE / Scanner ───────────────────────────────────────────────────────────
  String get notConnected  => _ga ? 'Gan ceangal'     : 'Not connected';
  String get eidReader     => _ga ? 'Léitheoir EID'   : 'EID Reader';
  String get connect       => _ga ? 'Ceangail'        : 'Connect';
  String get disconnect    => _ga ? 'Dícheangail'     : 'Disconnect';
  String get connectReader => _ga ? 'Ceangail Léitheoir' : 'Connect Reader';
  String get connectYourReader => _ga
      ? 'Ceangail do Léitheoir EID'
      : 'Connect your EID Reader';
  String get readerConnected   => _ga ? 'Léitheoir Ceangailte!' : 'Reader Connected!';
  String get continueToFarrax  => _ga ? 'Ar Aghaidh go Farrax' : 'Continue to Farrax';
  String get skipForNow        => _ga ? 'Scipeáil go fóill'     : 'Skip for now';

  // ─── Onboarding ──────────────────────────────────────────────────────────────
  String get welcomeToFarrax   => _ga ? 'Fáilte go Farrax'      : 'Welcome to Farrax';
  String get letsSetUpFarm     => _ga ? 'Déanaimis do fheirm a shocrú' : "Let's get your farm set up";
  String get getStarted        => _ga ? 'Tosaigh'               : 'Get Started';
  String get farmSetup         => _ga ? 'Socrú Feirme'          : 'Farm Setup';
  String get enterFarmDetails  => _ga ? 'Cuir isteach sonraí d\'fheirme' : 'Enter your farm details';
  String get farmName          => _ga ? 'Ainm na Feirme'        : 'Farm Name';
  String get herdNumber        => _ga ? 'Uimhir Tréada'         : 'Herd Number';
  String get country           => _ga ? 'Tír'                   : 'Country';
  String get address           => _ga ? 'Seoladh'               : 'Address';
  String get addressOptional   => _ga ? 'Seoladh (roghnach)'    : 'Address (optional)';

  // ─── Animals ─────────────────────────────────────────────────────────────────
  String get registerAnimal    => _ga ? 'Ainmhí a Chlárú'       : 'Register Animal';
  String get tagNumber         => _ga ? 'Uimhir Cluaise'        : 'Tag Number';
  String get breed             => _ga ? 'Pór'                   : 'Breed';
  String get sex               => _ga ? 'Gnéas'                 : 'Sex';
  String get male              => _ga ? 'Fireann'               : 'Male';
  String get female            => _ga ? 'Baineann'              : 'Female';
  String get dateOfBirth       => _ga ? 'Dáta Breithe'          : 'Date of Birth';
  String get damTag            => _ga ? 'Clib na Máthara'       : 'Dam Tag';
  String get damTagOptional    => _ga ? 'Clib na Máthara (roghnach)' : 'Dam Tag (optional)';
  String get sireTag           => _ga ? 'Clib an Athara'        : 'Sire Tag';
  String get sireTagOptional   => _ga ? 'Clib an Athara (roghnach)' : 'Sire Tag (optional)';
  String get notes             => _ga ? 'Nótaí'                 : 'Notes';
  String get notesOptional     => _ga ? 'Nótaí (roghnach)'      : 'Notes (optional)';
  String get openFullProfile   => _ga ? 'Oscail Próifíl Iomlán' : 'Open Full Profile';
  String get addToBatchList    => _ga ? 'Cuir le Liosta Bhaisc' : 'Add to Batch List';
  String get tagNotRegistered  => _ga ? 'Clib gan Clárú'        : 'Tag Not Registered';
  String get active            => _ga ? 'Gníomhach'             : 'Active';
  String get inactive          => _ga ? 'Neamhghníomhach'       : 'Inactive';

  // ─── Dashboard ───────────────────────────────────────────────────────────────
  String get goodMorning      => _ga ? 'Maidin mhaith'              : 'Good morning';
  String get goodAfternoon    => _ga ? 'Tráthnóna maith'            : 'Good afternoon';
  String get goodEvening      => _ga ? 'Oíche mhaith'               : 'Good evening';
  String get farmer           => _ga ? 'A Fheirmeoirí'              : 'Farmer';
  String get quickActions     => _ga ? 'Gníomhartha Tapa'           : 'Quick Actions';
  String get recentActivity   => _ga ? 'Gníomhaíocht le Déanaí'     : 'Recent Activity';
  String get registerCalf     => _ga ? 'Lao a Chlárú'               : 'Register Calf';
  String get recordMovement   => _ga ? 'Gluaiseacht a Thaifeadadh'  : 'Record Movement';
  String get healthEvent      => _ga ? 'Ócáid Sláinte'              : 'Health Event';
  String get scanTagLabel     => _ga ? 'Clib a Scanadh'             : 'Scan Tag';
  String get totalAnimals     => _ga ? 'Ainmhithe ar Fad'           : 'Total Animals';
  String get birthsMonth      => _ga ? 'Breitheanna (mí)'           : 'Births (month)';
  String get healthAlerts     => _ga ? 'Foláirimh Sláinte'          : 'Health Alerts';
  String get noActivityYet    => _ga ? 'Gan ghníomhaíocht fós.'     : 'No activity yet.';
  String get registerFirstAnimalHint => _ga
      ? 'Clár do chéad ainmhí chun tosú.'
      : 'Register your first animal to get started.';
  String get registerFirstAnimal     => _ga ? 'Clár an Chéad Ainmhí'    : 'Register First Animal';
  String get noReaderConnected       => _ga ? 'Gan léitheoir ceangailte' : 'No reader connected';

  // ─── Animals list ────────────────────────────────────────────────────────────
  String get myHerd           => _ga ? 'Mo Thréad'                  : 'My Herd';
  String get searchHint       => _ga ? 'Cuardaigh de réir clib nó póir…' : 'Search by tag or breed…';
  String get filterAll        => _ga ? 'Uile'                       : 'All';
  String get addAnimal        => _ga ? 'Ainmhí a Chur Leis'         : 'Add Animal';
  String get noAnimalsYet     => _ga ? 'Gan ainmhithe cláraithe fós' : 'No animals registered yet';
  String get tapBelowToRegister => _ga
      ? 'Buail an cnaipe thíos chun do chéad ainmhí a chlárú.'
      : 'Tap the button below to register\nyour first animal.';

  // ─── Health ──────────────────────────────────────────────────────────────────
  String get overview         => _ga ? 'Forbhreathnú'               : 'Overview';
  String get cabinetTab       => _ga ? 'Caibinéad'                  : 'Cabinet';
  String get tbTests          => _ga ? 'Tástálacha TB'              : 'TB Tests';
  String get alertsTab        => _ga ? 'Foláirimh'                  : 'Alerts';
  String get noHealthEvents   => _ga ? 'Gan imeachtaí sláinte taifeadta' : 'No health events recorded';
  String get addHealthEvent   => _ga ? 'Imeacht Sláinte a Chur Leis'    : 'Add Health Event';
  String get cabinetEmpty     => _ga ? 'Caibinéad cógais folamh'    : 'Medicine cabinet is empty';
  String get addMedicine      => _ga ? 'Cógas a Chur Leis'          : 'Add Medicine';
  String get noTbTests        => _ga ? 'Gan tástálacha TB taifeadta' : 'No TB tests recorded';
  String get addTbTest        => _ga ? 'Tástáil TB a Chur Leis'     : 'Add TB Test';
  String get noUnreadAlerts   => _ga ? 'Gan foláirimh gan léamh'    : 'No unread alerts';
  String get lowStock         => _ga ? 'Stoc Íseal'                 : 'Low Stock';

  // ─── Movements ───────────────────────────────────────────────────────────────
  String get filterIn         => _ga ? 'Isteach'                    : 'In';
  String get filterOut        => _ga ? 'Amach'                      : 'Out';
  String get thisMonth        => _ga ? 'An Mhí Seo'                 : 'This Month';
  String get noMovementsYet   => _ga ? 'Gan gluaiseachtaí taifeadta' : 'No movements recorded';
  String get unknownFarm      => _ga ? 'Feirm anaithnid'            : 'Unknown farm';
  String get add              => _ga ? 'Cuir Leis'                  : 'Add';

  // ─── Language names (always shown in their own language) ─────────────────────
  static const String english  = 'English';
  static const String gaeilge  = 'Gaeilge';
}
