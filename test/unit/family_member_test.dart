import 'package:flutter_test/flutter_test.dart';
import 'package:employee_connect/domain/entities/family_member.dart';
import 'package:employee_connect/data/models/family_member_model.dart';

void main() {
  group('FamilyMember Entity Tests', () {
    test('should correctly map from a Map', () {
      final map = {
        'id': 1,
        'name': 'John Doe',
        'nationalId': '123456789V',
        'birthday': '1990-01-01',
        'age': 34,
        'nationality': 'Sinhala',
        'religion': 'Buddhism',
        'educationQualification': 'Degree',
        'jobType': 'Government',
        'isSamurdiAid': 0,
        'isAswasumaAid': 1,
        'isWedihitiAid': 0,
        'isMahajanadaraAid': 0,
        'isAbhadithaAid': 0,
        'isShishshyadaraAid': 0,
        'isPilikadaraAid': 0,
        'isTuberculosisAid': 0,
        'isAnyAid': 1,
        'grade': 'None',
        'familyHeadType': 'Family Head - Male',
        'relationshipToHead': 'Head',
        'householdNumber': 'H-001',
        'dateOfModified': '2024-02-23',
      };

      final member = FamilyMemberModel.fromMap(map);

      expect(member.id, 1);
      expect(member.name, 'John Doe');
      expect(member.isAswasumaAid, true);
      expect(member.age, 34);
    });

    test('should correctly map to a Map', () {
      final member = FamilyMember(
        id: 1,
        name: 'Jane Doe',
        nationalId: '987654321V',
        birthday: DateTime(1995, 5, 20),
        age: 28,
        nationality: 'Tamil',
        religion: 'Hinduism',
        educationQualification: 'Diploma',
        jobType: 'Private',
        isSamurdiAid: true,
        isAswasumaAid: false,
        isWedihitiAid: false,
        isMahajanadaraAid: false,
        isAbhadithaAid: false,
        isShishshyadaraAid: false,
        isPilikadaraAid: false,
        isTuberculosisAid: false,
        isAnyAid: true,
        grade: 'None',
        familyHeadType: 'Family Head - Female',
        relationshipToHead: 'Head',
        householdNumber: 'H-002',
        dateOfModified: '2024-02-23',
      );

      final map = FamilyMemberModel.fromEntity(member).toMap();

      expect(map['name'], 'Jane Doe');
      expect(map['isSamurdiAid'], 1);
      expect(map['isAswasumaAid'], 0);
      expect(map['age'], 28);
    });
  });
}
