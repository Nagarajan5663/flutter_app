import 'package:flutter/material.dart';

class MyAccountPage extends StatefulWidget {
  const MyAccountPage({
    super.key,
  });

  @override
  State<MyAccountPage> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<MyAccountPage> {
  // ================================================================
  // CONTROLLERS
  // ================================================================

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController displayNameController =
      TextEditingController(
    text: 'sureshkaniyappan27',
  );

  final TextEditingController countryController =
      TextEditingController();

  final TextEditingController stateController =
      TextEditingController();

  final TextEditingController currentPasswordController =
      TextEditingController();

  final TextEditingController newPasswordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  // ================================================================
  // PROFILE VALUES
  // ================================================================

  String? selectedGender;
  String? selectedTimeZone;

  // ================================================================
  // MOBILE NUMBERS
  // ================================================================

  final List<TextEditingController> mobileControllers = [
    TextEditingController(),
  ];

  // ================================================================
  // TIME ZONES
  // ================================================================

  final List<String> timeZones = [
    'Africa/Abidjan',
    'Africa/Accra',
    'Africa/Addis_Ababa',
    'Africa/Algiers',
    'Africa/Asmara',
    'Africa/Bamako',
    'Africa/Bangui',
    'Africa/Banjul',
    'Africa/Bissau',
    'Africa/Blantyre',
    'Africa/Brazzaville',
    'Africa/Bujumbura',
    'Africa/Cairo',
    'Africa/Casablanca',
    'Africa/Ceuta',
    'Africa/Conakry',
    'Africa/Dakar',
    'Africa/Dar_es_Salaam',
    'Africa/Djibouti',
    'Africa/Douala',
    'Africa/El_Aaiun',
    'Africa/Freetown',
    'Africa/Gaborone',
    'Africa/Harare',
    'Africa/Johannesburg',
    'Africa/Juba',
    'Africa/Kampala',
    'Africa/Khartoum',
    'Africa/Kigali',
    'Africa/Kinshasa',
    'Africa/Lagos',
    'Africa/Libreville',
    'Africa/Lome',
    'Africa/Luanda',
    'Africa/Lubumbashi',
    'Africa/Lusaka',
    'Africa/Malabo',
    'Africa/Maputo',
    'Africa/Maseru',
    'Africa/Mbabane',
    'Africa/Mogadishu',
    'Africa/Monrovia',
    'Africa/Nairobi',
    'Africa/Ndjamena',
    'Africa/Niamey',
    'Africa/Nouakchott',
    'Africa/Ouagadougou',
    'Africa/Porto-Novo',
    'Africa/Sao_Tome',
    'Africa/Tripoli',
    'Africa/Tunis',
    'Africa/Windhoek',

    'America/Adak',
    'America/Anchorage',
    'America/Anguilla',
    'America/Antigua',
    'America/Araguaina',
    'America/Argentina/Buenos_Aires',
    'America/Argentina/Catamarca',
    'America/Argentina/Cordoba',
    'America/Argentina/Jujuy',
    'America/Argentina/La_Rioja',
    'America/Argentina/Mendoza',
    'America/Argentina/Rio_Gallegos',
    'America/Argentina/Salta',
    'America/Argentina/San_Juan',
    'America/Argentina/San_Luis',
    'America/Argentina/Tucuman',
    'America/Argentina/Ushuaia',
    'America/Asuncion',
    'America/Atikokan',
    'America/Atka',
    'America/Bahia',
    'America/Bahia_Banderas',
    'America/Barbados',
    'America/Belem',
    'America/Belize',
    'America/Blanc-Sablon',
    'America/Boa_Vista',
    'America/Bogota',
    'America/Boise',
    'America/Buenos_Aires',
    'America/Cambridge_Bay',
    'America/Campo_Grande',
    'America/Cancun',
    'America/Caracas',
    'America/Catamarca',
    'America/Cayenne',
    'America/Cayman',
    'America/Chicago',
    'America/Chihuahua',
    'America/Ciudad_Juarez',
    'America/Coral_Harbour',
    'America/Cordoba',
    'America/Costa_Rica',
    'America/Creston',
    'America/Cuiaba',
    'America/Curacao',
    'America/Danmarkshavn',
    'America/Dawson',
    'America/Dawson_Creek',
    'America/Denver',
    'America/Detroit',
    'America/Dominica',
    'America/Edmonton',
    'America/Eirunepe',
    'America/El_Salvador',
    'America/Ensenada',
    'America/Fort_Nelson',
    'America/Fort_Wayne',
    'America/Fortaleza',
    'America/Glace_Bay',
    'America/Godthab',
    'America/Goose_Bay',
    'America/Grand_Turk',
    'America/Grenada',
    'America/Guadeloupe',
    'America/Guatemala',
    'America/Guayaquil',
    'America/Guyana',
    'America/Halifax',
    'America/Havana',
    'America/Hermosillo',
    'America/Indiana/Indianapolis',
    'America/Indiana/Knox',
    'America/Indiana/Marengo',
    'America/Indiana/Petersburg',
    'America/Indiana/Tell_City',
    'America/Indiana/Vevay',
    'America/Indiana/Vincennes',
    'America/Indiana/Winamac',
    'America/Indianapolis',
    'America/Inuvik',
    'America/Iqaluit',
    'America/Jamaica',
    'America/Jujuy',
    'America/Juneau',
    'America/Kentucky/Louisville',
    'America/Kentucky/Monticello',
    'America/Knox_IN',
    'America/Kralendijk',
    'America/La_Paz',
    'America/Lima',
    'America/Los_Angeles',
    'America/Lower_Princes',
    'America/Maceio',
    'America/Managua',
    'America/Manaus',
    'America/Marigot',
    'America/Martinique',
    'America/Matamoros',
    'America/Mazatlan',
    'America/Mendoza',
    'America/Menominee',
    'America/Merida',
    'America/Metlakatla',
    'America/Mexico_City',
    'America/Miquelon',
    'America/Moncton',
    'America/Monterrey',
    'America/Montevideo',
    'America/Montreal',
    'America/Montserrat',
    'America/Nassau',
    'America/New_York',
    'America/Nipigon',
    'America/Nome',
    'America/Noronha',
    'America/North_Dakota/Beulah',
    'America/North_Dakota/Center',
    'America/North_Dakota/New_Salem',
    'America/Nuuk',
    'America/Ojinaga',
    'America/Panama',
    'America/Pangnirtung',
    'America/Paramaribo',
    'America/Phoenix',
    'America/Port-au-Prince',
    'America/Port_of_Spain',
    'America/Porto_Acre',
    'America/Porto_Velho',
    'America/Puerto_Rico',
    'America/Punta_Arenas',
    'America/Rainy_River',
    'America/Rankin_Inlet',
    'America/Recife',
    'America/Regina',
    'America/Resolute',
    'America/Rio_Branco',
    'America/Rosario',
    'America/Santa_Isabel',
    'America/Santarem',
    'America/Santiago',
    'America/Santo_Domingo',
    'America/Sao_Paulo',
    'America/Scoresbysund',
    'America/Shiprock',
    'America/Sitka',
    'America/St_Barthelemy',
    'America/St_Johns',
    'America/St_Kitts',
    'America/St_Lucia',
    'America/St_Thomas',
    'America/St_Vincent',
    'America/Swift_Current',
    'America/Tegucigalpa',
    'America/Thule',
    'America/Thunder_Bay',
    'America/Tijuana',
    'America/Toronto',
    'America/Tortola',
    'America/Vancouver',
    'America/Virgin',
    'America/Whitehorse',
    'America/Winnipeg',
    'America/Yakutat',
    'America/Yellowknife',

    'Asia/Calcutta',
    'Asia/Dhaka',
    'Asia/Dubai',
    'Asia/Hong_Kong',
    'Asia/Jakarta',
    'Asia/Jerusalem',
    'Asia/Kabul',
    'Asia/Karachi',
    'Asia/Kathmandu',
    'Asia/Kolkata',
    'Asia/Kuala_Lumpur',
    'Asia/Kuwait',
    'Asia/Macau',
    'Asia/Manila',
    'Asia/Muscat',
    'Asia/Rangoon',
    'Asia/Riyadh',
    'Asia/Seoul',
    'Asia/Shanghai',
    'Asia/Singapore',
    'Asia/Taipei',
    'Asia/Tehran',
    'Asia/Tokyo',
    'Asia/Ulaanbaatar',
    'Asia/Vientiane',
    'Asia/Yangon',
  ];

  // ================================================================
  // GENDER OPTIONS
  // ================================================================

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();
    countryController.dispose();
    stateController.dispose();

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    for (final controller in mobileControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ================================================================
  // ADD MOBILE NUMBER
  // ================================================================

  void _addMobileNumber() {
    setState(() {
      mobileControllers.add(
        TextEditingController(),
      );
    });
  }

  // ================================================================
  // REMOVE MOBILE NUMBER
  // ================================================================

  void _removeMobileNumber(int index) {
    if (mobileControllers.length == 1) {
      mobileControllers[index].clear();
      return;
    }

    final controller = mobileControllers.removeAt(index);
    controller.dispose();

    setState(() {});
  }

  // ================================================================
  // SAVE PROFILE
  // ================================================================

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile changes saved successfully.'),
      ),
    );
  }

  // ================================================================
  // UPDATE PASSWORD
  // ================================================================

  void _updatePassword() {
    if (newPasswordController.text !=
        confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'New password and confirm password do not match.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password updated successfully.'),
      ),
    );
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F5FA),
      child: Stack(
        children: [
          // ==========================================================
          // DECORATIVE BACKGROUND CIRCLES
          // ==========================================================

          Positioned(
            top: -180,
            right: -100,
            child: _backgroundCircle(
              420,
            ),
          ),

          Positioned(
            bottom: -220,
            left: -150,
            child: _backgroundCircle(
              430,
            ),
          ),

          // ==========================================================
          // CONTENT
          // ==========================================================

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              28,
              30,
              28,
              40,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1035,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // PAGE TITLE
                    // =================================================

                    const Text(
                      'My Account',
                      style: TextStyle(
                        color: Color(0xFF15385C),
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // =================================================
                    // TRIAL MESSAGE
                    // =================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8F3F7),
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Your free trial will end on December 2, 2026. (88 days remaining)',
                        style: TextStyle(
                          color: Color(0xFF27636B),
                          fontSize: 15,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =================================================
                    // PROFILE INFORMATION
                    // =================================================

                    _sectionTitle(
                      'Profile Information',
                    ),

                    const SizedBox(height: 14),

                    _buildProfileCard(),

                    const SizedBox(height: 30),

                    // =================================================
                    // CHANGE PASSWORD
                    // =================================================

                    _sectionTitle(
                      'Change Password',
                    ),

                    const SizedBox(height: 14),

                    _buildPasswordCard(),

                    const SizedBox(height: 25),

                    // =================================================
                    // FOOTER
                    // =================================================

                    const Center(
                      child: Text(
                        '© 2026 test. All Rights Reserved.',
                        style: TextStyle(
                          color: Color(0xFF777777),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BACKGROUND CIRCLE
  // ================================================================

  Widget _backgroundCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFE9EAF0),
      ),
    );
  }

  // ================================================================
  // SECTION TITLE
  // ================================================================

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF15385C),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          width: double.infinity,
          color: const Color(0xFFD5D7DC),
        ),
      ],
    );
  }

  // ================================================================
  // PROFILE CARD
  // ================================================================

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              28,
              30,
              28,
              25,
            ),
            child: Column(
              children: [
                // ==================================================
                // FIRST + LAST NAME
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _textField(
                        label: 'First Name',
                        controller:
                            firstNameController,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _textField(
                        label: 'Last Name',
                        controller:
                            lastNameController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // DISPLAY NAME
                // ==================================================

                _textField(
                  label: 'Display Name',
                  controller:
                      displayNameController,
                ),

                const SizedBox(height: 28),

                // ==================================================
                // GENDER + TIME ZONE
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _genderDropdown(),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _timeZoneField(),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // COUNTRY + STATE
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _textField(
                        label: 'Country/Region',
                        controller:
                            countryController,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _textField(
                        label: 'State',
                        controller:
                            stateController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  height: 1,
                  color: const Color(0xFFE1E1E1),
                ),

                const SizedBox(height: 28),

                // ==================================================
                // MOBILE NUMBERS
                // ==================================================

                Align(
                  alignment:
                      Alignment.centerLeft,
                  child: const Text(
                    'Mobile Number(s)',
                    style: TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Column(
                  children: List.generate(
                    mobileControllers.length,
                    (index) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child:
                                  _mobileField(
                                controller:
                                    mobileControllers[
                                        index],
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            // REMOVE BUTTON
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: Material(
                                color: const Color(
                                  0xFFF8D8DC,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  6,
                                ),
                                child: InkWell(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    6,
                                  ),
                                  onTap: () {
                                    _removeMobileNumber(
                                      index,
                                    );
                                  },
                                  child:
                                      const Center(
                                    child: Text(
                                      '×',
                                      style:
                                          TextStyle(
                                        color: Color(
                                          0xFF8B1E2D,
                                        ),
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ==================================================
                // ADD NUMBER
                // ==================================================

                Align(
                  alignment:
                      Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed:
                        _addMobileNumber,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(
                        0xFFF0F0F0,
                      ),
                      foregroundColor:
                          const Color(
                        0xFF333333,
                      ),
                      elevation: 0,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 20,
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          6,
                        ),
                      ),
                    ),
                    child: const Text(
                      '+ Add Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ========================================================
          // SAVE BUTTON FOOTER
          // ========================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              28,
              18,
              28,
              18,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFCFCFC),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE1E1E1),
                ),
              ),
            ),
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saveChanges,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1687E8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // PASSWORD CARD
  // ================================================================

  Widget _buildPasswordCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              28,
              30,
              28,
              28,
            ),
            child: Column(
              children: [
                // ==================================================
                // EMAIL + ROLE
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _disabledField(
                        label: 'Email Address',
                        value:
                            'sureshkaniyappan27@gmail.com',
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _disabledField(
                        label: 'My Role',
                        value: 'Super Admin',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Container(
                  height: 1,
                  color: const Color(0xFFE1E1E1),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // CURRENT PASSWORD
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _passwordField(
                        label:
                            'Current Password',
                        controller:
                            currentPasswordController,
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // NEW + CONFIRM PASSWORD
                // ==================================================

                Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _passwordField(
                        label: 'New Password',
                        controller:
                            newPasswordController,
                      ),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: _passwordField(
                        label:
                            'Confirm New Password',
                        controller:
                            confirmPasswordController,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ========================================================
          // UPDATE PASSWORD FOOTER
          // ========================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              28,
              18,
              28,
              18,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFCFCFC),
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE1E1E1),
                ),
              ),
            ),
            child: Align(
              alignment:
                  Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF1687E8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 13,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      6,
                    ),
                  ),
                ),
                child: const Text(
                  'Update Password',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // TEXT FIELD
  // ================================================================

  Widget _textField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF444444),
            ),
            decoration: _inputDecoration(),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // MOBILE FIELD
  // ================================================================

  Widget _mobileField({
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType:
            TextInputType.phone,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF444444),
        ),
        decoration: _inputDecoration(
          hintText: 'Enter mobile number',
        ),
      ),
    );
  }

  // ================================================================
  // PASSWORD FIELD
  // ================================================================

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: _inputDecoration(),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DISABLED FIELD
  // ================================================================

  Widget _disabledField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            enabled: false,
            controller:
                TextEditingController(text: value),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  const Color(0xFFF1F1F6),
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
              ),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(7),
                borderSide:
                    const BorderSide(
                  color: Color(0xFFDCDDE2),
                ),
              ),
              disabledBorder:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(7),
                borderSide:
                    const BorderSide(
                  color: Color(0xFFDCDDE2),
                ),
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // GENDER DROPDOWN
  // ================================================================

  Widget _genderDropdown() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: _dropdownTheme(
            child: DropdownButtonFormField<String>(
            initialValue: selectedGender,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            hint: const Text(
              '-- Select --',
              style: TextStyle(
                color: Color(0xFF555555),
                fontSize: 15,
              ),
            ),
            items: genderOptions
                .map(
                  (gender) =>
                      DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
            decoration:
                _inputDecoration(),
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
            ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // TIME ZONE FIELD
  // ================================================================

  Widget _timeZoneField() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Zone',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: _dropdownTheme(
            child: DropdownButtonFormField<String>(
            initialValue: selectedTimeZone,
            dropdownColor: Colors.white,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
            hint: const Text(
              'Search and select a time zone',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 15,
              ),
            ),
            items: timeZones
                .map(
                  (timeZone) =>
                      DropdownMenuItem<String>(
                    value: timeZone,
                    child: Text(
                      timeZone,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedTimeZone = value;
              });
            },
            decoration: _inputDecoration(),
            menuMaxHeight: 320,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 20,
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropdownTheme({required Widget child}) {
    const blueHighlight = Color(0xFF2563EB);

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
        hoverColor: blueHighlight,
        highlightColor: blueHighlight,
        splashColor: blueHighlight,
      ),
      child: child,
    );
  }

  // ================================================================
  // INPUT DECORATION
  // ================================================================

  InputDecoration _inputDecoration({
    String? hintText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF999999),
        fontSize: 15,
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 12,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFDCDDE2),
        ),
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFFDCDDE2),
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(7),
        borderSide: const BorderSide(
          color: Color(0xFF1687E8),
          width: 1.2,
        ),
      ),
    );
  }
}
