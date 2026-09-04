import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.blue,
      elevation: 1,
      titleSpacing: 16,

      // LOGO
      title: const Text(
        'logo',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),

      actions: [
        // SUPER ADMIN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              // Building + User icon circle
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.apartment_rounded,
                      color: Colors.blue,
                      size: 22,
                    ),

                    Positioned(
                      right: 3,
                      bottom: 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.blue,
                          size: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              
            ],
          ),
        ),

        // LOGOUT
        IconButton(
          tooltip: 'Logout',
          onPressed: () {},
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ),

        const SizedBox(width: 8),
      ],
    );
  }
}