import 'package:flutter/material.dart';

import 'design/design_system.dart';
import 'widgets/contact_social_widget.dart';

/// SSS (Sıkça Sorulan Sorular) sayfası (/sss).
/// Sorular kategorilere ayrılmış akordiyon kartlarıyla sunulur.
class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Sıkça Sorulan Sorular'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: colors.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.help_outline_rounded,
                            size: 14,
                            color: colors.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SSS',
                            style: AppTypography.labelMedium.copyWith(
                              color: colors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  Text(
                    'Sıkça Sorulan Sorular',
                    textAlign: TextAlign.center,
                    style: AppTypography.headline.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  Text(
                    'Aklınıza takılan her şeyin yanıtı burada. '
                    'Bir soruya tıklayarak yanıtını görüntüleyin.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s48),
                  ..._categories.map(
                    (category) => _FaqCategorySection(category: category),
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  const SutolContactCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Veri ─────────────────────────────────────

class _FaqCategory {
  const _FaqCategory({required this.label, required this.items});

  final String label;
  final List<_FaqItem> items;
}

class _FaqItem {
  const _FaqItem({required this.question, required this.blocks});

  final String question;
  final List<_FaqBlock> blocks;
}

/// [lead] kısmı kalın, geri kalan normal; [isBullet] madde işareti olup
/// olmadığını belirtir.
class _FaqBlock {
  const _FaqBlock.paragraph(String text, {String? lead})
      : isBullet = false,
        text = text,
        lead = lead;

  const _FaqBlock.bullet(String text, {String? lead})
      : isBullet = true,
        text = text,
        lead = lead;

  final bool isBullet;
  final String text;
  final String? lead;
}

const List<_FaqCategory> _categories = [
  _FaqCategory(
    label: 'GENEL',
    items: [
      _FaqItem(
        question: 'Sutols nedir?',
        blocks: [
          _FaqBlock.paragraph(
            'Sutols, tek bir cümle ile profesyonel sunumlar oluşturmanızı '
            'sağlayan yapay zeka destekli bir platformdur. Konunuzu yazın, '
            'yapay zeka içeriği araştırıp hazırlasın, siz de istediğiniz '
            'gibi düzenleyin.',
          ),
        ],
      ),
      _FaqItem(
        question: "Sutols'u kimler kullanabilir?",
        blocks: [
          _FaqBlock.paragraph(
            'Öğrenciler, öğretmenler, girişimciler, pazarlama ekipleri, '
            'danışmanlar — sunum hazırlaması gereken herkes. Ücretsiz '
            'katmanla hemen başlayabilirsiniz.',
          ),
        ],
      ),
      _FaqItem(
        question: 'Bir sunum oluşturmak ne kadar sürer?',
        blocks: [
          _FaqBlock.paragraph(
            'Konunuzu yazıp "Oluştur" dedikten sonra, yapay zeka genellikle '
            'birkaç saniye içinde tüm slaytları hazırlar. Sonrasında '
            'dilediğiniz kadar düzenleyebilirsiniz.',
          ),
        ],
      ),
    ],
  ),
  _FaqCategory(
    label: "SUTOLS'UN FARKI",
    items: [
      _FaqItem(
        question: "Sutols'u diğer sunum araçlarından "
            '(Canva, Gamma, PowerPoint) ayıran nedir?',
        blocks: [
          _FaqBlock.paragraph(
            'interaktif 3D model kütüphanesi.',
            lead: 'En büyük farkımız: ',
          ),
          _FaqBlock.paragraph(
            'Çoğu sunum aracı, görsel olarak sadece düz resimler, ikonlar '
            'veya basit çizimler sunar. Sutols\'da ise binlerce gerçek 3D '
            'model — analiz çerçeveleri (SWOT küpleri, PESTEL çarkları), '
            '3B grafikler, diyagramlar, semboller — sunumunuza doğrudan '
            'eklenebilir. Bu modeller:',
          ),
          _FaqBlock.bullet(
            'Döndürülebilir ve hareket ettirilebilir — düz bir resim '
            'değil, gerçek 3 boyutlu nesneler',
          ),
          _FaqBlock.bullet(
            'Sunum sırasında canlı — izleyicileriniz statik bir slayt '
            'değil, etkileşimli bir görsel deneyim görür',
          ),
          _FaqBlock.bullet(
            'Konuya özel eşleştirilir — yapay zeka, yazdığınız konuya '
            'göre en uygun 3D modelleri otomatik seçer',
          ),
        ],
      ),
      _FaqItem(
        question: 'Diğer farklarımız neler?',
        blocks: [
          _FaqBlock.bullet(
            'Şablon aramanıza, sıfırdan tasarlamanıza gerek yok — '
            'konunuzu yazmanız yeterli',
            lead: 'Tek cümleyle başlangıç: ',
          ),
          _FaqBlock.bullet(
            'Sutols, girdiğiniz konu hakkında içerik üretirken güncel ve '
            'isabetli bilgiler kullanır',
            lead: 'Yapay zeka araştırma yapar: ',
          ),
          _FaqBlock.bullet(
            'Kullanıcıların en çok beğendiği tasarım ve içerik yapıları '
            'zamanla öğrenilir, öneriler gitgide iyileşir',
            lead: 'Sürekli gelişen sistem: ',
          ),
          _FaqBlock.bullet(
            'Ücretsiz katmanla başlayabilir, ihtiyacınız büyüdükçe '
            'planınızı yükseltebilirsiniz',
            lead: 'Katmanlı erişim: ',
          ),
        ],
      ),
      _FaqItem(
        question: '3D modelleri nereden alıyorsunuz, kaliteleri nasıl?',
        blocks: [
          _FaqBlock.paragraph(
            'Model kütüphanemiz özenle seçilmiş ve kategorize edilmiş '
            'binlerce profesyonel 3D varlıktan oluşur; sürekli yeni '
            'modeller eklenmektedir.',
          ),
        ],
      ),
    ],
  ),
  _FaqCategory(
    label: 'HESAP VE ÜYELİK',
    items: [
      _FaqItem(
        question: 'Ücretsiz katmanda neler yapabilirim?',
        blocks: [
          _FaqBlock.paragraph(
            'Günlük belirli sayıda sunum oluşturabilir, temel model '
            'kütüphanesine erişebilir ve 5 slaytlık sunumlar '
            'hazırlayabilirsiniz.',
          ),
        ],
      ),
      _FaqItem(
        question: 'Ücretli planlara geçince ne değişir?',
        blocks: [
          _FaqBlock.paragraph(
            'Günlük sunum limitiniz artar, genişletilmiş/tüm model '
            'kütüphanesine erişirsiniz ve daha uzun/detaylı sunumlar '
            '(8, 12, hatta 20 slayt) oluşturabilirsiniz.',
          ),
        ],
      ),
      _FaqItem(
        question: 'Planımı istediğim zaman değiştirebilir miyim?',
        blocks: [
          _FaqBlock.paragraph(
            'Evet, dilediğiniz zaman yükseltme veya düşürme yapabilirsiniz.',
          ),
        ],
      ),
    ],
  ),
  _FaqCategory(
    label: 'İÇERİK VE KULLANIM',
    items: [
      _FaqItem(
        question: 'Oluşturduğum sunumları nereden bulabilirim?',
        blocks: [
          _FaqBlock.paragraph(
            'Üst menüdeki "Sunumlarım" bölümünden, bugüne kadar '
            'oluşturduğunuz tüm sunumlara erişebilirsiniz.',
          ),
        ],
      ),
      _FaqItem(
        question: 'Sunumumu nasıl paylaşırım/indiririm?',
        blocks: [
          _FaqBlock.paragraph(
            'Editördeki "Dışa Aktar" butonuyla sunumunuzu HTML formatında '
            'indirip, tarayıcı üzerinden istediğiniz yerde açıp '
            'sunabilirsiniz.',
          ),
        ],
      ),
      _FaqItem(
        question: '3D modelleri ayrıca indirebilir miyim?',
        blocks: [
          _FaqBlock.paragraph(
            'Hayır, model kütüphanemiz yalnızca Sutols sunumları içinde '
            'kullanım için lisanslanmıştır; modellerin ayrı olarak '
            'indirilmesi veya başka platformlarda kullanılması '
            'desteklenmez.',
          ),
        ],
      ),
      _FaqItem(
        question: 'Oluşturduğum içerik başka biriyle aynı mı çıkar?',
        blocks: [
          _FaqBlock.paragraph(
            'Hayır, yapay zeka her istek için özgün içerik üretir; aynı '
            'konuyu yazsanız bile sonuç kişiselleştirilmiş olur.',
          ),
        ],
      ),
    ],
  ),
  _FaqCategory(
    label: 'TEKNİK',
    items: [
      _FaqItem(
        question: 'Sutols hangi cihazlarda çalışır?',
        blocks: [
          _FaqBlock.paragraph(
            'Sutols tamamen tarayıcı tabanlıdır — bilgisayar, tablet veya '
            'telefon üzerinden, herhangi bir kurulum yapmadan '
            'kullanabilirsiniz.',
          ),
        ],
      ),
      _FaqItem(
        question: 'Verilerim güvende mi?',
        blocks: [
          _FaqBlock.paragraph(
            'verileriniz endüstri standardı altyapılarda (Google Firebase) '
            'güvenli şekilde saklanır. Detaylar için Gizlilik '
            'Politikamızı inceleyebilirsiniz.',
            lead: 'Evet, ',
          ),
        ],
      ),
      _FaqItem(
        question: 'Bir hata ile karşılaşırsam ne yapmalıyım?',
        blocks: [
          _FaqBlock.paragraph(
            ' e-posta adresinden veya Instagram\'da @sutolscom hesabımızdan bize dilediğiniz zaman ulaşabilirsiniz.',
            lead: 'contact@sutols.com',
          ),
        ],
      ),
    ],
  ),
];

// ── Görünüm ───────────────────────────────────

class _FaqCategorySection extends StatelessWidget {
  const _FaqCategorySection({required this.category});

  final _FaqCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.s4,
              bottom: AppSpacing.s12,
            ),
            child: Text(
              category.label,
              style: AppTypography.labelMedium.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...category.items.map((item) => _FaqCard(item: item)),
        ],
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  const _FaqCard({required this.item});

  final _FaqItem item;

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;

  void _toggle() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s8),
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _expanded
              ? colors.accent.withValues(alpha: 0.45)
              : colors.border.withValues(alpha: 0.8),
        ),
        boxShadow: _expanded ? AppShadows.sm : AppShadows.none,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: AppSpacing.s12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: AppTypography.titleMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: AppMotion.fast,
                    curve: AppMotion.easeOut,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: _expanded ? colors.accent : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: AppMotion.standard,
            curve: AppMotion.easeOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _FaqAnswer(blocks: widget.item.blocks)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _FaqAnswer extends StatelessWidget {
  const _FaqAnswer({required this.blocks});

  final List<_FaqBlock> blocks;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks.map((block) => _buildBlock(block, colors)).toList(),
      ),
    );
  }

  Widget _buildBlock(_FaqBlock block, AppColors colors) {
    final baseStyle = AppTypography.bodyMedium.copyWith(
      color: colors.textSecondary,
      height: 1.6,
    );
    final leadStyle = baseStyle.copyWith(
      color: colors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    final rich = Text.rich(
      TextSpan(
        children: [
          if (block.lead != null) TextSpan(text: block.lead, style: leadStyle),
          TextSpan(text: block.text, style: baseStyle),
        ],
      ),
    );

    if (!block.isBullet) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s8),
        child: rich,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: colors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(child: rich),
        ],
      ),
    );
  }
}
