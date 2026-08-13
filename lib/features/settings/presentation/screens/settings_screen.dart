import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tarim_app/core/theme/app_colors.dart';

import '../../../../core/services/notification_prefs.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/fade_page_route.dart';
import '../../../../core/utils/localization_helper.dart';

/// Bildirim tercihleri ve dil.
///
/// Uygulamanın ilk ayar ekranı. Var olma sebebi tek bir ölçülebilir gerçek:
/// bildirimden rahatsız olan okuyucunun elindeki tek araç tarayıcı iznini
/// tamamen kapatmaktı — yani "sabah özeti istemiyorum" demenin bedeli son
/// dakika haberlerini de kaybetmekti. Tür bazlı anahtarlar bu ya-hep-ya-hiç
/// seçimini ortadan kaldırıyor.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late Future<bool> _permission;

  @override
  void initState() {
    super.initState();
    _permission = ref.read(notificationServiceProvider).isPermissionGranted();
  }

  Future<void> _requestPermission() async {
    final granted =
        await ref.read(notificationServiceProvider).requestPermission();
    if (!mounted) return;
    setState(() {
      _permission = Future.value(granted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    final bgColor = isDark ? AppColors.darkGreen : AppColors.creamBackground;
    final textColor = isDark ? AppColors.creamBackground : AppColors.earthText;
    final subtleColor = isDark
        ? AppColors.wheat
        : AppColors.earthText.withValues(alpha: 0.70);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popScreen(context),
          tooltip: isEn ? 'Back' : 'Geri',
        ),
        title: Text(
          isEn ? 'Settings' : 'Ayarlar',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: textColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  isEn ? 'Notifications' : 'Bildirimler',
                  color: textColor,
                ),
                const SizedBox(height: 8),
                FutureBuilder<bool>(
                  future: _permission,
                  builder: (context, snapshot) {
                    // Cevap gelene kadar anahtarlar gösterilmiyor: bir an
                    // "izin yok" uyarısı gösterip sonra kaldırmak, izni zaten
                    // vermiş kullanıcıyı boşuna telaşlandırırdı.
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    if (snapshot.data != true) {
                      return _PermissionCard(
                        isEn: isEn,
                        isDark: isDark,
                        textColor: textColor,
                        subtleColor: subtleColor,
                        onRequest: _requestPermission,
                      );
                    }
                    return _KindSwitches(
                      isEn: isEn,
                      textColor: textColor,
                      subtleColor: subtleColor,
                    );
                  },
                ),
                const SizedBox(height: 40),
                _SectionTitle(
                  isEn ? 'Language' : 'Dil',
                  color: textColor,
                ),
                const SizedBox(height: 8),
                Text(
                  isEn
                      ? 'Applies to both the interface and notification text.'
                      : 'Hem arayüz hem de bildirim metni için geçerlidir.',
                  style: GoogleFonts.inter(fontSize: 13, color: subtleColor),
                ),
                const SizedBox(height: 12),
                const _LanguageChoice(),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 1.2,
        color: color,
      ),
    );
  }
}

/// İzin verilmemişken anahtarların yerine çıkan kart.
///
/// Anahtarları izinsizken göstermek yanıltıcı olurdu: kullanıcı hepsini açık
/// bırakır, hiç bildirim almaz ve sebebini hiçbir yerde göremezdi.
class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.isEn,
    required this.isDark,
    required this.textColor,
    required this.subtleColor,
    required this.onRequest,
  });

  final bool isEn;
  final bool isDark;
  final Color textColor;
  final Color subtleColor;
  final Future<void> Function() onRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.wheat.withValues(alpha: 0.08)
            : AppColors.wheat.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? 'Notifications are off' : 'Bildirimler kapalı',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'Turn on notifications to choose which ones you receive.'
                : 'Hangi bildirimleri alacağınızı seçebilmek için önce '
                    'bildirimlere izin vermeniz gerekiyor.',
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: subtleColor,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRequest,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 44),
            ),
            child: Text(
              isEn ? 'Turn on notifications' : 'Bildirimlere izin ver',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'If you previously blocked them, you need to allow '
                    'notifications for this site in your browser settings.'
                : 'Daha önce engellediyseniz, tarayıcı ayarlarından bu siteye '
                    'bildirim iznini yeniden vermeniz gerekir.',
            style: GoogleFonts.inter(fontSize: 12, color: subtleColor),
          ),
        ],
      ),
    );
  }
}

class _KindSwitches extends ConsumerWidget {
  const _KindSwitches({
    required this.isEn,
    required this.textColor,
    required this.subtleColor,
  });

  final bool isEn;
  final Color textColor;
  final Color subtleColor;

  static const _labels = <NotificationKind, (String, String, String, String)>{
    NotificationKind.breaking: (
      'Son Dakika',
      'Önemli gelişmeler yayımlandığı anda.',
      'Breaking News',
      'The moment an important story is published.',
    ),
    NotificationKind.morning: (
      'Günün Gündemi',
      'Her sabah 07:00’de günün öne çıkan haberleri.',
      'Daily Briefing',
      'The day’s top stories, every morning at 07:00.',
    ),
    NotificationKind.weekly: (
      'Haftanın Özeti',
      'Pazar akşamı haftanın derlemesi.',
      'Weekly Recap',
      'A roundup of the week, Sunday evening.',
    ),
    NotificationKind.author: (
      'Köşe Yazıları',
      'Yeni bir köşe yazısı yayımlandığında.',
      'Columns',
      'When a new column is published.',
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationPrefsProvider);

    return Column(
      children: [
        for (final kind in NotificationKind.values)
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: enabled.contains(kind),
            activeThumbColor: AppColors.primaryGreen,
            onChanged: (value) async {
              await ref
                  .read(notificationPrefsProvider.notifier)
                  .setEnabled(kind, value);
              // Tercih diske yazıldıktan SONRA sunucuya taşınıyor; sıra
              // önemli, çünkü kayıt diskteki değeri okuyor.
              await ref.read(notificationServiceProvider).syncPreferences();
            },
            title: Text(
              isEn ? _labels[kind]!.$3 : _labels[kind]!.$1,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: textColor,
              ),
            ),
            subtitle: Text(
              isEn ? _labels[kind]!.$4 : _labels[kind]!.$2,
              style: GoogleFonts.inter(fontSize: 12, color: subtleColor),
            ),
          ),
      ],
    );
  }
}

class _LanguageChoice extends ConsumerWidget {
  const _LanguageChoice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'tr', label: Text('Türkçe')),
        ButtonSegment(value: 'en', label: Text('English')),
      ],
      selected: {code},
      showSelectedIcon: false,
      onSelectionChanged: (selection) async {
        ref.read(localeProvider.notifier).setLocale(
              localeFromCode(selection.first),
            );
        // Bildirim metninin dili de bu seçime bakıyor; cihaz kaydı hemen
        // güncellenmezse okuyucu bir sonraki bildirimini eski dilde alır.
        await ref.read(notificationServiceProvider).syncPreferences();
      },
    );
  }
}
