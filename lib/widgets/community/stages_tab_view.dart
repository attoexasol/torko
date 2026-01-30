import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/community/stage_join_dialog.dart';

class StagesTabView extends StatelessWidget {
  final List<Map<String, dynamic>> stages;
  final bool isDark;
  final bool isBn;

  const StagesTabView({
    super.key,
    required this.stages,
    required this.isDark,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: stages.length,
      itemBuilder: (context, index) {
        return _buildStageCard(context, stages[index]);
      },
    );
  }

  Widget _buildStageCard(BuildContext context, Map<String, dynamic> stage) {
    return GestureDetector(
      onTap: () {
        StageJoinDialog.show(context, stage);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? const Color(0xFF0d3a4a) : const Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(int.parse(stage['categoryColor'].toString().replaceFirst('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    stage['category'].toString(),
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (stage['isLive'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBn ? 'লাইভ' : 'LIVE',
                          style: GoogleFonts.notoSansBengali(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              stage['title'].toString(),
              style: GoogleFonts.notoSansBengali(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFd97757),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      stage['hostName'].toString()[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage['hostName'].toString(),
                        style: GoogleFonts.notoSansBengali(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${stage['joinedCount']} ${isBn ? 'শ্রোতা' : 'listeners'}',
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '⊙',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stage['duration'].toString(),
                            style: GoogleFonts.notoSansBengali(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF9D9D9D) : const Color(0xFF9D9D9D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Get.snackbar(
                  isBn ? 'স্টেজে যোগ দেওয়া হয়েছে' : 'Joined Stage',
                  isBn ? '${stage['title']} স্টেজে যোগ দেওয়া হয়েছে' : 'Joined ${stage['title']} stage',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFd97757),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    isBn ? 'স্টেজে যোগ দিন' : 'Join Stage',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
