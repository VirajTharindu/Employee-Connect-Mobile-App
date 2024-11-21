// main.dart

import 'package:flutter/material.dart';
import 'package:village_officer_app/Samurdhi.dart';

import 'Aswasuma.dart';
import 'Wedihiti.dart';
import 'Mahajanadara.dart';
import 'Abhadhitha.dart';

import 'family_member.dart';
import 'Shishyadara.dart';
import 'Pilikadara.dart';

import 'AnyAid.dart';
import 'School_Students.dart';
import 'Government.dart';
import 'SemiGovernmentScreen.dart';
import 'PrivateScreen.dart';
import 'CorporationsScreen.dart';
import 'ForcesScreen.dart';
import 'PoliceScreen.dart';
import 'SelfEmployedScreen.dart';
import 'NoJobScreen.dart';
import 'Higher_Educational_Levels_of_Adults.dart';
import 'People_Based_on_Religions.dart';
import 'People_Based_on_Ethnicity.dart';
import 'People_Based_on_Age_Groups.dart';
import 'People_Based_on_Age_Groups_Legally.dart';
import 'Aids.dart';
import 'Jobs.dart';
import 'ShareDBUI.dart';
import 'importDB.dart';
import 'Update_family_Member_Data.dart';
import 'family_member_form.dart';
import 'family_list.dart';
import 'family_profile.dart';

void main() {
  runApp(const VillageOfficerApp());
}

class VillageOfficerApp extends StatelessWidget {
  const VillageOfficerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Village Officer App',
      routes: {
        '/family_member_form': (context) => FamilyMemberForm(),
        '/family_list': (context) => FamilyList(),
        '/family_profile': (context) => const FamilyProfile(
              familyMembers: [],
            ),
        '/Samurdhi': (context) => SamurdhiFamiliesScreen(),
        '/Aswasuma': (context) => AswasumaFamiliesScreen(),
        '/Wedihiti': (context) => WedihitiFamiliesScreen(),
        '/Mahajanadara': (context) => MahajanadaraFamiliesScreen(),
        '/Abhadhitha': (context) => AbhadithaFamiliesScreen(),
        '/Shishyadara': (context) => ShishshyadaraFamiliesScreen(),
        '/Pilikadara': (context) => PilikadaraFamiliesScreen(),
        '/AnyAid': (context) => AnyAidFamiliesScreen(),
        '/School_Students': (context) => SchoolStudentsScreen(),
        '/Government': (context) => GovernmentScreen(),
        '/Private': (context) => PrivateScreen(),
        '/Semi-Government': (context) => SemiGovernmentScreen(),
        '/Corporations': (context) => CorporationsScreen(),
        '/Forces': (context) => ForcesScreen(),
        '/Police': (context) => PoliceScreen(),
        '/Self-Employed': (context) => SelfEmployedScreen(),
        '/No Job': (context) => NoJobScreen(),
        '/Higher Education': (context) =>
            HigherEducationalLevelsOfAdultsScreen(),
        '/Religion': (context) => PeopleBasedOnReligionsScreen(),
        '/Ethnicity': (context) => PeopleBasedOnEthnicityScreen(),
        '/Age': (context) => PeopleBasedOnAgeGroups(),
        '/AgeLegally': (context) => PeopleBasedOnAgeGroupsLegally(),
        '/Aids': (context) => AidsScreen(),
        '/Jobs': (context) => JobsScreen(),
        '/ShareDB': (context) => DatabaseScreen(),
        '/Update': (context) => const UpdateFamilyMemberData(
              householdNumber: '',
              familyMembers: [],
            ),
        '/ImportDB': (context) => ImportDatabaseScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FamilyMemberForm(),
    );
  }
}
