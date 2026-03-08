// family_report_service.dart

import 'package:employee_connect/domain/entities/family_member.dart';
import 'package:employee_connect/domain/repositories/family_repository.dart';

class FamilyReportService {
  final FamilyRepository _repository;

  FamilyReportService(this._repository);

  Future<Map<String, List<FamilyMember>>> getPeopleBasedOnAgeGroups() async {
    final List<FamilyMember> members = await _repository.retrieveAllFamilyMembers();

    Map<String, List<FamilyMember>> ageGroups = {
      'Infants and Toddlers (0-4 years)': [],
      'Children (5-14 years)': [],
      'Youth (15-24 years)': [],
      'Adults (25-54 years)': [],
      'Older Adults (55-64 years)': [],
      'Seniors (65+ years)': [],
    };

    for (var member in members) {
      if (member.age >= 0 && member.age <= 4) {
        ageGroups['Infants and Toddlers (0-4 years)']!.add(member);
      } else if (member.age >= 5 && member.age <= 14) {
        ageGroups['Children (5-14 years)']!.add(member);
      } else if (member.age >= 15 && member.age <= 24) {
        ageGroups['Youth (15-24 years)']!.add(member);
      } else if (member.age >= 25 && member.age <= 54) {
        ageGroups['Adults (25-54 years)']!.add(member);
      } else if (member.age >= 55 && member.age <= 64) {
        ageGroups['Older Adults (55-64 years)']!.add(member);
      } else if (member.age >= 65) {
        ageGroups['Seniors (65+ years)']!.add(member);
      }
    }

    return ageGroups;
  }

  Future<Map<String, List<FamilyMember>>> getPeopleBasedOnAgeGroupsLegally() async {
    final List<FamilyMember> members = await _repository.retrieveAllFamilyMembers();

    Map<String, List<FamilyMember>> ageGroups = {
      'Children (<18 years)': [],
      'Adults (18+ years)': [],
    };

    for (var member in members) {
      if (member.age < 18) {
        ageGroups['Children (<18 years)']!.add(member);
      } else {
        ageGroups['Adults (18+ years)']!.add(member);
      }
    }

    return ageGroups;
  }
  
  // You can add more grouping logic here for ethnicity, religion etc. if needed
  // Current UI logic often groups data inside the Widget build or dedicated fetch methods.
}
