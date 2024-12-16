import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'family_member.dart';
import 'package:intl/intl.dart';

class FamilyMemberForm extends StatefulWidget {
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
                    bool isHouseholdUnique = await DatabaseHelper()
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

                      bool isNationalIdUnique = await DatabaseHelper()
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
                      await DatabaseHelper().insertFamilyMember(member);
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
                  children: const [
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
        Text(
          index == 0
              ? 'Family Head'
              : 'Family Member ${index + 1}', // Change label for first member
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        if (index == 0)
          _buildFamilyHeadTypeDropdown(), // Dropdown for family head
        TextFormField(
          decoration: const InputDecoration(labelText: 'Name'),
          validator: (value) => value!.isEmpty ? 'Enter name' : null,
          onSaved: (value) => familyMembers[index].name = value!,
        ),

        GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate:
                  defaultBirthday, // Start from default when opening the picker
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
            decoration: InputDecoration(
              labelText: 'Birthday',
              hintText: 'Select Date of Birth', // Placeholder text
              errorText: (!isBirthdaySelected && isSubmitPressed) ||
                      familyMembers[index].birthday.isAfter(DateTime.now())
                  ? 'Select a valid date of birth'
                  : null, // Show error only if submit is pressed and birthday not selected
            ),
            child: Text(
              isBirthdaySelected
                  ? "${familyMembers[index].birthday.toLocal()}"
                      .split(' ')[0] // Display selected date
                  : 'Select Date of Birth', // Display placeholder if date not explicitly selected
            ),
          ),
        ),

        TextFormField(
          decoration: const InputDecoration(labelText: 'National ID'),
          validator: (value) {
            if (familyMembers[index].age <= 16) {
              // Skip validation for members under 16
              return null;
            }
            return value!.isEmpty ? 'Enter National ID' : null;
          },
          onSaved: (value) => familyMembers[index].nationalId = value ?? '',
        ),

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Nationality'),
          value: familyMembers[index].nationality.isNotEmpty
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

        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Religion'),
          value: familyMembers[index].religion.isNotEmpty
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

        // Only display the grade dropdown for family members other than the family head
        if (index != 0) _buildGradeDropdown(familyMembers[index], index),

        if (familyMembers[index].grade == 'None')
          DropdownButtonFormField<String>(
            decoration:
                const InputDecoration(labelText: 'Education Qualification'),
            value: (familyMembers[index].educationQualification != null &&
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

        if (familyMembers[index].grade == 'None')
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Job Type'),
            value: (familyMembers[index].jobType != null &&
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

        if (index != 0)
          _buildRelationshipToHeadField(index), // Relationship for others
        _buildAidCheckboxes(index),
        const SizedBox(height: 10),
      ],
    );
  }

  // Dropdown for family head type
  Widget _buildFamilyHeadTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Family Head Type'),
      value: selectedFamilyHeadType,

      hint: const Text('Select Family Head Type'), // Placeholder text

      items: const [
        DropdownMenuItem(
            child: Text('Family Head - Male'), value: 'Family Head - Male'),
        DropdownMenuItem(
            child: Text('Family Head - Female'), value: 'Family Head - Female'),
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
      decoration:
          const InputDecoration(labelText: 'Relationship to Family Head'),
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
          '* If a student?', // Add the sub-label here
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: 'Grade'),
          value: member.grade,
          items: const [
            DropdownMenuItem(child: Text('None'), value: 'None'),
            DropdownMenuItem(child: Text('Preschool'), value: 'Preschool'),
            DropdownMenuItem(child: Text('1'), value: '1'),
            DropdownMenuItem(child: Text('2'), value: '2'),
            DropdownMenuItem(child: Text('3'), value: '3'),
            DropdownMenuItem(child: Text('4'), value: '4'),
            DropdownMenuItem(child: Text('5'), value: '5'),
            DropdownMenuItem(child: Text('6'), value: '6'),
            DropdownMenuItem(child: Text('7'), value: '7'),
            DropdownMenuItem(child: Text('8'), value: '8'),
            DropdownMenuItem(child: Text('9'), value: '9'),
            DropdownMenuItem(child: Text('10'), value: '10'),
            DropdownMenuItem(child: Text('11'), value: '11'),
            DropdownMenuItem(child: Text('12'), value: '12'),
            DropdownMenuItem(child: Text('13'), value: '13'),
          ],
          onChanged: (value) {
            setState(() {
              member.grade = value;
              // Update the UI to conditionally display the education field
            });
          },
          validator: (value) => value == null ? 'Select a grade' : null,
        ),
      ],
    );
  }

  String? _validateBirthday(DateTime birthday) {
    final DateTime today = DateTime.now();
    if (!isBirthdaySelected && isSubmitPressed) {
      return 'Please select a date of birth';
    }
    if (birthday.isAfter(today)) {
      return 'Date of birth cannot be in the future';
    }
    return null;
  }

  // Builds checkboxes for each type of aid
  Widget _buildAidCheckboxes(int index) {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Receiving Samurdi Aid'),
          value: familyMembers[index].isSamurdiAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isSamurdiAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Aswasuma Aid'),
          value: familyMembers[index].isAswasumaAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isAswasumaAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Adult Aid'),
          value: familyMembers[index].isWedihitiAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isWedihitiAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Mahajanadara Aid'),
          value: familyMembers[index].isMahajanadaraAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isMahajanadaraAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Disability Aid'),
          value: familyMembers[index].isAbhadithaAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isAbhadithaAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Student Aid'),
          value: familyMembers[index].isShishshyadaraAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isShishshyadaraAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Cancer Aid'),
          value: familyMembers[index].isPilikadaraAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isPilikadaraAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Tuberculosis Aid'),
          value: familyMembers[index].isTuberculosisAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isTuberculosisAid = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Receiving Any Aid'),
          value: familyMembers[index].isAnyAid,
          onChanged: (bool? value) {
            setState(() {
              familyMembers[index].isAnyAid = value!;
            });
          },
        ),
      ],
    );
  }
}
