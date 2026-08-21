import 'package:flutter/material.dart';

import '../routes.dart';
import 'design/design_system.dart';
import 'widgets/contact_social_widget.dart';

/// Gizlilik Politikası (/gizlilik) ve Kullanım Şartları (/sartlar) sayfaları.
/// Metinler başlangıç taslağıdır; yasal inceleme sonrası güncellenmelidir.

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'Geri',
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
