import 'package:flutter/material.dart';

import '../routes.dart';
import '../state/language_controller.dart';
import 'design/design_system.dart';
import 'widgets/contact_social_widget.dart';

/// Gizlilik Politikası (/gizlilik, /en/privacy) ve Kullanım Şartları (/sartlar, /en/terms) sayfaları.

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageController.instance.isEnglish;

    if (isEn) {
      return const LegalPageScaffold(
        title: 'Privacy Policy',
        updatedLabel: 'Last updated: August 2026',
        children: [
          _Section(
            title: 'Introduction',
            paragraphs: [
              'This policy explains what information is collected and how it is used when you use Sutols.',
            ],
          ),
          _Section(
            title: 'Information We Collect',
            bullets: [
              'Account information: email address, display name (profile details if signed in with Google)',
              'Usage data: generated presentations, edits made to slides, export frequency, and editor session duration',
              'Technical data: approximate city, region, and country derived from IP address and browser client data (for security and service quality). Precise GPS location is never collected.',
            ],
          ),
          _Section(
            title: 'Why We Collect This Information',
            bullets: [
              'To manage your account and securely store your presentations',
              'To improve our service: analyzing design and content structures favored by users to optimize future slide generation. This analysis is aggregated and anonymized; individual content is never sold or shared with third parties.',
              'To comply with legal obligations',
            ],
          ),
          _Section(
            title: 'Third-Party Services',
            paragraphs: [
              'We rely on the following third-party infrastructure providers to deliver Sutols:',
            ],
            bullets: [
              'Google Firebase (authentication, database, hosting)',
              'Google Gemini AI (presentation content generation — topic prompt is transmitted to Google for slide creation)',
              'Cloudflare (3D model asset CDN and content delivery)',
              'IPWho (approximate geographic lookup from IP address)',
            ],
            paragraphsAfter: [
              'Each third-party service operates under its respective privacy policy.',
            ],
          ),
          _Section(
            title: 'Your Rights',
            bullets: [
              'Request a copy of your stored data',
              'Request deletion of your account and associated presentations',
              'Opt out of optional usage collection (certain features may be limited)',
            ],
          ),
          _ContactSection(),
        ],
      );
    }

    return const LegalPageScaffold(
      title: 'Gizlilik Politikası',
      updatedLabel: 'Son güncelleme: Ağustos 2026',
      children: [
        _Section(
          title: 'Giriş',
          paragraphs: [
            'Bu politika, Sutols\'u kullanırken hangi verilerinizin toplandığını ve nasıl kullanıldığını açıklar.',
          ],
        ),
        _Section(
          title: 'Topladığımız veriler',
          bullets: [
            'Hesap bilgileri: e-posta adresi, ad (Google ile giriş yaptıysanız profil bilgileriniz)',
            'Kullanım verileri: oluşturduğunuz sunumlar, bu sunumlar üzerinde yaptığınız düzenlemeler, sunumları ne sıklıkla dışa aktardığınız, editörde geçirdiğiniz süre',
            'Teknik veriler: IP adresinden türetilen yaklaşık şehir, bölge ve ülke bilgisi ile tarayıcı bilgisi (güvenlik ve hizmet kalitesi için). GPS konumu ve kesin adres toplanmaz.',
          ],
        ),
        _Section(
          title: 'Bu verileri neden topluyoruz',
          bullets: [
            'Hesabınızı yönetmek ve sunumlarınızı saklamak için',
            'Sistemi geliştirmek için: hangi tasarım ve içerik yapılarının kullanıcılar tarafından beğenildiğini anlayarak, gelecekteki sunum önerilerimizi iyileştiriyoruz. Bu analiz anonim ve toplu istatistikler üzerinden yapılır, bireysel içeriğiniz üçüncü taraflarla paylaşılmaz.',
            'Yasal yükümlülüklerimizi yerine getirmek için',
          ],
        ),
        _Section(
          title: 'Üçüncü taraf hizmetler',
          paragraphs: [
            'Sutols\'u çalıştırmak için şu hizmetleri kullanıyoruz:',
          ],
          bullets: [
            'Google Firebase (kimlik doğrulama, veritabanı, barındırma)',
            'Google Gemini AI (sunum içeriği üretimi — girdiğiniz konu metni, içerik üretimi için Google\'a iletilir)',
            'Cloudflare (3D model dosyaları ve içerik dağıtım ağı)',
            'IPWho (IP adresinden yaklaşık şehir, bölge ve ülke tespiti)',
          ],
          paragraphsAfter: [
            'Bu hizmetlerin kendi gizlilik politikaları geçerlidir.',
          ],
        ),
        _Section(
          title: 'Haklarınız',
          bullets: [
            'Verilerinizin bir kopyasını talep edebilirsiniz',
            'Hesabınızın ve verilerinizin silinmesini talep edebilirsiniz',
            'Kullanım verisi toplamayı sınırlamayı talep edebilirsiniz (bazı özellikler bu durumda kısıtlanabilir)',
          ],
        ),
        _ContactSection(),
      ],
    );
  }
}

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isEn = LanguageController.instance.isEnglish;

    if (isEn) {
      return const LegalPageScaffold(
        title: 'Terms of Service',
        updatedLabel: 'Last updated: August 2026',
        children: [
          _Section(
            title: 'General',
            paragraphs: [
              'By accessing or using Sutols, you agree to be bound by the following terms.',
            ],
          ),
          _TermsItem(
            number: '1',
            title: 'Account',
            text:
                'You must register with accurate information and maintain the confidentiality of your account credentials.',
          ),
          _TermsItem(
            number: '2',
            title: 'Content',
            text:
                'You are solely responsible for the content of your presentations. You may not use Sutols to generate unlawful, infringing, or harmful material.',
          ),
          _TermsItem(
            number: '3',
            title: '3D Model Library',
            text:
                '3D assets on Sutols are licensed exclusively for presentation creation within the platform. Extracting, downloading, redistributing, or using 3D models outside Sutols is strictly prohibited.',
          ),
          _TermsItem(
            number: '4',
            title: 'Usage Data',
            text:
                'Presentations created on Sutols and user interactions (editing, exporting, etc.) may be analyzed in aggregate to refine and improve the service.',
          ),
          _TermsItem(
            number: '5',
            title: 'Membership Tiers',
            text:
                'The Free tier has daily quota limits. Upgrades, subscriptions, and cancellation terms are outlined on the Pricing page.',
          ),
          _TermsItem(
            number: '6',
            title: 'No Warranty',
            text:
                'Sutols is provided "as is" without warranty of uninterrupted or error-free operation.',
          ),
          _TermsItem(
            number: '7',
            title: 'Modifications',
            text:
                'These terms may be updated periodically. Material changes will be communicated to users.',
          ),
          _ContactSection(),
        ],
      );
    }

    return const LegalPageScaffold(
      title: 'Kullanım Şartları',
      updatedLabel: 'Son güncelleme: Ağustos 2026',
      children: [
        _Section(
          title: 'Genel',
          paragraphs: [
            'Sutols\'u kullanarak aşağıdaki şartları kabul etmiş olursunuz.',
          ],
        ),
        _TermsItem(
          number: '1',
          title: 'Hesap',
          text:
              'Doğru bilgilerle kayıt olmalı, hesap güvenliğinizden siz sorumlusunuz.',
        ),
        _TermsItem(
          number: '2',
          title: 'İçerik',
          text:
              'Oluşturduğunuz sunumların içeriğinden siz sorumlusunuz. Yasa dışı, telif hakkı ihlali içeren veya zararlı içerik üretmek için Sutols\'u kullanamazsınız.',
        ),
        _TermsItem(
          number: '3',
          title: '3D Model Kütüphanesi',
          text:
              'Platformdaki 3D modeller yalnızca Sutols içinde sunum oluşturmak amacıyla kullanılabilir. Modelleri ayrı olarak indirmek, kopyalamak, yeniden dağıtmak veya Sutols dışında kullanmak yasaktır.',
        ),
        _TermsItem(
          number: '4',
          title: 'Kullanım verisi',
          text:
              'Sutols\'u kullanırken oluşturduğunuz sunumlar ve bu sunumlarla etkileşiminiz (düzenleme, dışa aktarma vb.), hizmeti geliştirmek amacıyla analiz edilebilir.',
        ),
        _TermsItem(
          number: '5',
          title: 'Üyelik katmanları',
          text:
              'Ücretsiz katmanda günlük kullanım sınırı vardır. Ücretli katmanlara geçiş ve iptal koşulları Fiyatlandırma sayfasında belirtilir.',
        ),
        _TermsItem(
          number: '6',
          title: 'Hizmet garantisi yok',
          text:
              'Sutols "olduğu gibi" sunulur, kesintisiz veya hatasız çalışacağı garanti edilmez.',
        ),
        _TermsItem(
          number: '7',
          title: 'Değişiklikler',
          text:
              'Bu şartlar zaman zaman güncellenebilir, önemli değişikliklerde bilgilendirileceksiniz.',
        ),
        _ContactSection(),
      ],
    );
  }
}

class LegalPageScaffold extends StatelessWidget {
  const LegalPageScaffold({
    super.key,
    required this.title,
    required this.updatedLabel,
    required this.children,
  });

  final String title;
  final String updatedLabel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Title(
      title: '$title – Sutols',
      color: colors.accent,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: tr('Geri', 'Back'),
            onPressed: () => AppRoutes.handleAppBack(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: AppTypography.headline.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      updatedLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s24),
                    const Divider(),
                    const SizedBox(height: AppSpacing.s16),
                    ...children,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.paragraphsAfter = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<String> paragraphsAfter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppSpacing.s24),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.s8),
        ...paragraphs.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Text(p,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.textSecondary)),
          ),
        ),
        if (bullets.isNotEmpty)
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 5,
                      color: colors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: Text(
                      b,
                      style: AppTypography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ...paragraphsAfter.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.s8),
            child: Text(p,
                style: AppTypography.bodyMedium
                    .copyWith(color: colors.textSecondary)),
          ),
        ),
      ],
    );
  }
}

class _TermsItem extends StatelessWidget {
  const _TermsItem({
    required this.number,
    required this.title,
    required this.text,
  });

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: AppTypography.labelMedium.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Text(
                  text,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return const SutolContactCard();
  }
}
