import 'package:flutter/material.dart';
import 'package:employee_connect/core/service_locator.dart';
import 'package:employee_connect/domain/entities/family_member.dart';

class FamilyMemberForm extends StatefulWidget {
  const FamilyMemberForm({super.key});

  @override
  _FamilyMemberFormState createState() => _FamilyMemberFormState();
}

class _FamilyMemberFormState extends State<FamilyMemberForm> {
  final _formKey = GlobalKey<FormState>();
  int familyMemberCount = 1;
  List<FamilyMember> familyMembers = [];
  String familyHouseholdNumber = '';
  String? selectedFamilyHeadType;
  String? selectedJobType;

  // Define these variables for tracking the initial state
  DateTime defaultBirthday = DateTime(2000, 1, 1); // Default date for birthday
  bool isBirthdaySelected = false; // Track if the user has selected a date
  bool isSubmitPressed = false; // Track if the submit button was pressed

  // Controllers for the household number and National IDs for each member
  TextEditingController householdController = TextEditingController();
  List<TextEditingController> nationalIdControllers =
      List.generate(5, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    selectedFamilyHeadType = 'Family Head - Male'; // Set a default value
    _updateFamilyMembersList(familyMemberCount);
    familyMembers[0].familyHeadType =
        selectedFamilyHeadType!; // Set for family head
  }

  // Method to update the familyMembers list based on the count
  void _updateFamilyMembersList(int count) {
    setState(() {
      familyMembers = List.generate(
        count,
        (index) => FamilyMember(
            name: '',
            nationalId: '',
            birthday: DateTime(2000, 1, 1), // Default date: January 1, 2000
            age: 0,
            nationality: '',
            religion: '',
            educationQualification: '',
            jobType: '',
            familyHeadType: '',
            // Default for family head
            relationshipToHead: '',
            householdNumber: '',
            grade: 'None',
            dateOfModified: ''),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Data Entry'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String value) {
              switch (value) {
                case 'Family List':
                  Navigator.pushNamed(context, '/family_list');
                  break;

                case 'Aid Types':
                  Navigator.pushNamed(context, '/Aids');
                  break;

                case 'Job Types':
                  Navigator.pushNamed(context, '/Jobs');
                  break;

                case 'School Students':
                  Navigator.pushNamed(context, '/School_Students');
                  break;

                case 'Higher Education Levels of Adults':
                  Navigator.pushNamed(context, '/Higher Education');
                  break;

                case 'People Based on Religion':
                  Navigator.pushNamed(context, '/Religion');
                  break;

                case 'People Based on Ethnicity':
                  Navigator.pushNamed(context, '/Ethnicity');
                  break;

                case 'People Based on Age Groups':
                  Navigator.pushNamed(context, '/Age');
                  break;

                case 'People Based on Age Groups (Legally)':
                  Navigator.pushNamed(context, '/AgeLegally');
                  break;

                case 'Share Database':
                  Navigator.pushNamed(context, '/ShareDB');
                  break;

                case 'Import Database':
                  Navigator.pushNamed(context, '/ImportDB');
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {
                'Family List',
                'Aid Types',
                'Job Types',
                'School Students',
                'Higher Education Levels of Adults',
                'People Based on Religion',
                'People Based on Ethnicity',
                'People Based on Age Groups',
                'People Based on Age Groups (Legally)',
                'Share Database',
                'Import Database',
              }.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Household Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter a unique household number';
                  }
                  return null;
                },
                onSaved: (value) {
                  familyHouseholdNumber = value!;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Number of Family Members'),
                keyboardType: TextInputType.number,
                initialValue: familyMemberCount.toString(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter the number of family members';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
                onChanged: (value) {
                  int? count = int.tryParse(value);
                  if (count != null && count > 0) {
                    familyMemberCount = count;
                    _updateFamilyMembersList(familyMemberCount);
                  }
                },
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < familyMemberCount; i++)
                _buildFamilyMemberForm(i),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () async {
                  setState(() {
                    isSubmitPressed =
                        true; // Set this to true when the button is clicked
                  });
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Check if household number is unique
                    bool isHouseholdUnique = await locator.familyRepository
                        .isHouseholdNumberUnique(familyHouseholdNumber);
                    if (!isHouseholdUnique) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Household number already exists'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // Stop execution if household number is not unique
                    }

                    // Check if all national IDs are unique
                    bool allNationalIdsUnique = true;
                    for (var member in familyMembers) {
                      // Skip if the national ID is empty or null
                      if (member.nationalId == null ||
                          member.nationalId == '') {
                        continue; // Skip this member if the national ID is empty or null
                      }

                      bool isNationalIdUnique = await locator.familyRepository
                          .isNationalIdUnique(member.nationalId);
                      if (!isNationalIdUnique) {
                        allNationalIdsUnique = false;
                        break;
                      }
                    }

                    if (!allNationalIdsUnique) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('One or more National IDs already exist'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return; // Stop execution if any national ID is not unique
                    }

                    for (var member in familyMembers) {
                      // Set the household number for each member
                      member.householdNumber = familyHouseholdNumber;
                      await locator.familyRepository.insertFamilyMember(member);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Family Members Saved'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Clear the form
                    _formKey.currentState?.reset(); // Reset all form fields
                    familyHouseholdNumber = ''; // Reset household number
                    familyMemberCount = 1; // Reset member count
                    _updateFamilyMembersList(
                        familyMemberCount); // Reinitialize members

                    // Navigate to FamilyList and pass the household number
                    Navigator.pushNamed(context, '/family_list',
                        arguments: familyHouseholdNumber);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 24), // Add a save icon
                    SizedBox(width: 8), // Space between icon and text
                    Text('Save'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the form for each family member
  Widget _buildFamilyMemberForm(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          index == 0
              ? 'Family Head'
              : 'Family Member ${index + 1}',
          style: const TextStyle(
            fontSize: 22, // Increased size
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),

        if (index == 0)
          _buildFamilyHeadTypeDropdown(),
        
        TextFormField(
          decoration: _buildInputDecoration('Name'),
          validator: (value) => value!.isEmpty ? 'Enter name' : null,
          onSaved: (value) => familyMembers[index].name = value!,
        ),
        const SizedBox(height: 15),

        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: defaultBirthday,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                familyMembers[index].birthday = picked;
                familyMembers[index].age = DateTime.now().year - picked.year;
                isBirthdaySelected = true;
              });
            }
          },
          child: InputDecorator(
            decoration: _buildInputDecoration('Birthday').copyWith(
              hintText: 'Select Date of Birth',
              errorText: (!isBirthdaySelected && isSubmitPressed) ||
                      familyMembers[index].birthday.isAfter(DateTime.now())
                  ? 'Select a valid date of birth'
                  : null,
            ),
            child: Text(
              isBirthdaySelected
                  ? "${familyMembers[index].birthday.toLocal()}".split(' ')[0]
                  : 'Select Date of Birth',
              style: TextStyle(
                fontSize: 16,
                color: isBirthdaySelected ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        TextFormField(
          decoration: _buildInputDecoration('National ID'),
          validator: (value) {
            if (familyMembers[index].age <= 16) {
              return null;
            }
            return value!.isEmpty ? 'Enter National ID' : null;
          },
          onSaved: (value) => familyMembers[index].nationalId = value ?? '',
        ),
        const SizedBox(height: 15),

        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Nationality'),
          initialValue: familyMembers[index].nationality.isNotEmpty
              ? familyMembers[index].nationality
              : null,
          items: ['Sinhala', 'Tamil', 'Muslim', 'Malay', 'Burgher', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            familyMembers[index].nationality = value!;
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Select nationality' : null,
          onSaved: (value) => familyMembers[index].nationality = value ?? '',
        ),
        const SizedBox(height: 15),

        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Religion'),
          initialValue: familyMembers[index].religion.isNotEmpty
              ? familyMembers[index].religion
              : null,
          items: ['Buddhism', 'Hinduism', 'Islam', 'Christianity', 'Other']
              .map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            familyMembers[index].religion = value!;
          },
          validator: (value) =>
              value == null || value.isEmpty ? 'Select religion' : null,
          onSaved: (value) => familyMembers[index].religion = value ?? '',
        ),
        const SizedBox(height: 15),

        if (index != 0) _buildGradeDropdown(familyMembers[index], index),

        if (familyMembers[index].grade == 'None') ...[
          DropdownButtonFormField<String>(
            decoration: _buildInputDecoration('Education Qualification'),
            initialValue:
                (familyMembers[index].educationQualification != null &&
                        familyMembers[index].educationQualification!.isNotEmpty)
                    ? familyMembers[index].educationQualification
                    : null,
            items: [
              'Primary (1-5)',
              'Junior Secondary (6-9)',
              'Senior Secondary (10-11)',
              'O/L passed',
              'Collegiate Level (12-13)',
              'A/L passed',
              'Diploma',
              'Degree',
              'Higher Studies',
              'No Schooling'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              familyMembers[index].educationQualification = value!;
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Select education qualification'
                : null,
            onSaved: (value) =>
                familyMembers[index].educationQualification = value ?? '',
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            decoration: _buildInputDecoration('Job Type'),
            initialValue: (familyMembers[index].jobType != null &&
                    familyMembers[index].jobType!.isNotEmpty)
                ? familyMembers[index].jobType
                : null,
            items: [
              'Government',
              'Private',
              'Semi-Government',
              'Corporations',
              'Forces',
              'Police',
              'Self-Employed (Business)',
              'No Job'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              familyMembers[index].jobType = value!;
            },
            validator: (value) =>
                value == null || value.isEmpty ? 'Select job type' : null,
            onSaved: (value) => familyMembers[index].jobType = value ?? '',
          ),
          const SizedBox(height: 15),
        ],

        if (index != 0) ...[
          _buildRelationshipToHeadField(index),
          const SizedBox(height: 15),
        ],
        _buildAidCheckboxes(index),
        const SizedBox(height: 10),
        const Divider(thickness: 1.5),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700], fontSize: 16),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2.0),
      ),
    );
  }

  // Dropdown for family head type
  Widget _buildFamilyHeadTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: _buildInputDecoration('Family Head Type'),
      initialValue: selectedFamilyHeadType,
      items: const [
        DropdownMenuItem(
            value: 'Family Head - Male', child: Text('Family Head - Male')),
        DropdownMenuItem(
            value: 'Family Head - Female', child: Text('Family Head - Female')),
      ],
      onChanged: (value) {
        setState(() {
          selectedFamilyHeadType = value;
          familyMembers[0].familyHeadType = value ?? '';
        });
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Select family head type' : null,
      onSaved: (value) => familyMembers[0].familyHeadType = value ?? '',
    );
  }

  // Relationship field for family members other than the head
  Widget _buildRelationshipToHeadField(int index) {
    return TextFormField(
      decoration: _buildInputDecoration('Relationship to Family Head'),
      validator: (value) => value!.isEmpty ? 'Enter relationship' : null,
      onSaved: (value) => familyMembers[index].relationshipToHead = value!,
    );
  }

  // Grade dropdown for family members
  Widget _buildGradeDropdown(FamilyMember member, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '* If a student?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        DropdownButtonFormField<String>(
          decoration: _buildInputDecoration('Grade'),
          initialValue: member.grade,
          items: const [
            DropdownMenuItem(value: 'None', child: Text('None')),
            DropdownMenuItem(value: 'Preschool', child: Text('Preschool')),
            DropdownMenuItem(value: '1', child: Text('1')),
            DropdownMenuItem(value: '2', child: Text('2')),
            DropdownMenuItem(value: '3', child: Text('3')),
            DropdownMenuItem(value: '4', child: Text('4')),
            DropdownMenuItem(value: '5', child: Text('5')),
            DropdownMenuItem(value: '6', child: Text('6')),
            DropdownMenuItem(value: '7', child: Text('7')),
            DropdownMenuItem(value: '8', child: Text('8')),
            DropdownMenuItem(value: '9', child: Text('9')),
            DropdownMenuItem(value: '10', child: Text('10')),
            DropdownMenuItem(value: '11', child: Text('11')),
            DropdownMenuItem(value: '12', child: Text('12')),
            DropdownMenuItem(value: '13', child: Text('13')),
          ],
          onChanged: (value) {
            setState(() {
              member.grade = value;
            });
          },
          validator: (value) => value == null ? 'Select a grade' : null,
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Builds checkboxes for each type of aid
  Widget _buildAidCheckboxes(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Aid Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        _buildCheckbox('Receiving Samurdi Aid', familyMembers[index].isSamurdiAid, (val) {
          setState(() => familyMembers[index].isSamurdiAid = val!);
        }),
        _buildCheckbox('Receiving Aswasuma Aid', familyMembers[index].isAswasumaAid, (val) {
          setState(() => familyMembers[index].isAswasumaAid = val!);
        }),
        _buildCheckbox('Receiving Adult Aid', familyMembers[index].isWedihitiAid, (val) {
          setState(() => familyMembers[index].isWedihitiAid = val!);
        }),
        _buildCheckbox('Receiving Mahajanadara Aid', familyMembers[index].isMahajanadaraAid, (val) {
          setState(() => familyMembers[index].isMahajanadaraAid = val!);
        }),
        _buildCheckbox('Receiving Disability Aid', familyMembers[index].isAbhadithaAid, (val) {
          setState(() => familyMembers[index].isAbhadithaAid = val!);
        }),
        _buildCheckbox('Receiving Student Aid', familyMembers[index].isShishshyadaraAid, (val) {
          setState(() => familyMembers[index].isShishshyadaraAid = val!);
        }),
        _buildCheckbox('Receiving Cancer Aid', familyMembers[index].isPilikadaraAid, (val) {
          setState(() => familyMembers[index].isPilikadaraAid = val!);
        }),
        _buildCheckbox('Receiving Tuberculosis Aid', familyMembers[index].isTuberculosisAid, (val) {
          setState(() => familyMembers[index].isTuberculosisAid = val!);
        }),
        _buildCheckbox('Receiving Any Aid', familyMembers[index].isAnyAid, (val) {
          setState(() => familyMembers[index].isAnyAid = val!);
        }),
      ],
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      activeColor: Colors.green,
    );
  }
}
