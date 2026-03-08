import 'package:flutter/material.dart';
import 'package:employee_connect/presentation/pages/auth/license_activation_page.dart';
import 'package:employee_connect/presentation/pages/family/family_member_form_page.dart';
import 'package:employee_connect/presentation/pages/family/family_list_page.dart';
import 'package:employee_connect/presentation/pages/family/family_profile_page.dart';
import 'package:employee_connect/presentation/pages/family/update_family_member_data_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/samurdhi_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/aswasuma_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/wedihiti_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/mahajanadara_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/abhadhitha_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/shishyadara_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/pilikadara_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/any_aid_page.dart';
import 'package:employee_connect/presentation/pages/reports/school_students_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/government_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/semi_government_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/private_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/corporations_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/forces_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/police_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/self_employed_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/no_job_page.dart';
import 'package:employee_connect/presentation/pages/reports/statistics/higher_educational_levels_of_adults_page.dart';
import 'package:employee_connect/presentation/pages/reports/statistics/people_based_on_religions_page.dart';
import 'package:employee_connect/presentation/pages/reports/statistics/people_based_on_ethnicity_page.dart';
import 'package:employee_connect/presentation/pages/reports/statistics/people_based_on_age_groups_page.dart';
import 'package:employee_connect/presentation/pages/reports/statistics/people_based_on_age_groups_legally_page.dart';
import 'package:employee_connect/presentation/pages/reports/aids/aids_page.dart';
import 'package:employee_connect/presentation/pages/reports/employment/jobs_page.dart';
import 'package:employee_connect/presentation/pages/settings/share_db_page.dart';
import 'package:employee_connect/presentation/pages/settings/import_db_page.dart';

class AppRoutes {
  static const String license = '/License';
  static const String home = '/Home';
  static const String familyList = '/family_list';
  static const String familyProfile = '/family_profile';
  static const String samurdhi = '/Samurdhi';
  static const String aswasuma = '/Aswasuma';
  static const String wedihiti = '/Wedihiti';
  static const String mahajanadara = '/Mahajanadara';
  static const String abhadhitha = '/Abhadhitha';
  static const String shishyadara = '/Shishyadara';
  static const String pilikadara = '/Pilikadara';
  static const String anyAid = '/AnyAid';
  static const String schoolStudents = '/School_Students';
  static const String government = '/Government';
  static const String private = '/Private';
  static const String semiGovernment = '/Semi-Government';
  static const String corporations = '/Corporations';
  static const String forces = '/Forces';
  static const String police = '/Police';
  static const String selfEmployed = '/Self-Employed';
  static const String noJob = '/No Job';
  static const String higherEducation = '/Higher Education';
  static const String religion = '/Religion';
  static const String ethnicity = '/Ethnicity';
  static const String age = '/Age';
  static const String ageLegally = '/AgeLegally';
  static const String aids = '/Aids';
  static const String jobs = '/Jobs';
  static const String shareDB = '/ShareDB';
  static const String update = '/Update';
  static const String importDB = '/ImportDB';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      license: (context) => const LicenseActivationPage(),
      home: (context) => FamilyMemberForm(),
      familyList: (context) => FamilyList(),
      familyProfile: (context) => const FamilyProfile(familyMembers: []),
      samurdhi: (context) => SamurdhiFamiliesScreen(),
      aswasuma: (context) => AswasumaFamiliesScreen(),
      wedihiti: (context) => WedihitiFamiliesScreen(),
      mahajanadara: (context) => MahajanadaraFamiliesScreen(),
      abhadhitha: (context) => AbhadithaFamiliesScreen(),
      shishyadara: (context) => ShishshyadaraFamiliesScreen(),
      pilikadara: (context) => PilikadaraFamiliesScreen(),
      anyAid: (context) => AnyAidFamiliesScreen(),
      schoolStudents: (context) => SchoolStudentsScreen(),
      government: (context) => GovernmentScreen(),
      private: (context) => PrivateScreen(),
      semiGovernment: (context) => SemiGovernmentScreen(),
      corporations: (context) => CorporationsScreen(),
      forces: (context) => ForcesScreen(),
      police: (context) => PoliceScreen(),
      selfEmployed: (context) => SelfEmployedScreen(),
      noJob: (context) => NoJobScreen(),
      higherEducation: (context) => HigherEducationalLevelsOfAdultsScreen(),
      religion: (context) => PeopleBasedOnReligionsScreen(),
      ethnicity: (context) => PeopleBasedOnEthnicityScreen(),
      age: (context) => PeopleBasedOnAgeGroups(),
      ageLegally: (context) => PeopleBasedOnAgeGroupsLegally(),
      aids: (context) => AidsScreen(),
      jobs: (context) => JobsScreen(),
      shareDB: (context) => DatabaseScreen(),
      update: (context) => const UpdateFamilyMemberData(householdNumber: '', familyMembers: []),
      importDB: (context) => ImportDatabaseScreen(),
    };
  }
}
