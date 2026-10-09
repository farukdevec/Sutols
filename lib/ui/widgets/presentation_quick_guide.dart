import 'package:flutter/material.dart';
import '../../state/language_controller.dart';

Future<void> showPresentationQuickGuide(BuildContext context) =>
    showDialog<void>(
        context: context, builder: (_) => const _PresentationQuickGuide());

class _PresentationQuickGuide extends StatefulWidget {
  const _PresentationQuickGuide();
  @override
  State<_PresentationQuickGuide> createState() =>
      _PresentationQuickGuideState();
}

class _PresentationQuickGuideState extends State<_PresentationQuickGuide> {
  int _step = 0;

  @override
  Widget build(BuildContext context) {
    final steps = <(IconData, String, String)>[
      (
        Icons.auto_awesome_outlined,
        tr('Fikrini slaytlara dönüştür', 'Turn your idea into slides'),
        tr('Ana sayfada konunu, dilini ve sayfa sayısını seç. Oluşan sunumu editörde gözden geçir; doğruluğunu ve anlatım sırasını kontrol et.',
            'Choose your topic, language and slide count on the home page. Review the generated presentation in the editor for accuracy and narrative order.')
      ),
      (
        Icons.text_fields_rounded,
        tr('Metni ve düzeni iyileştir', 'Refine text and layout'),
        tr('Sahnede metni seçerek düzenle. Kutuları taşı ve boyutlandır. Metin panelindeki Okunurluğu kontrol et düğmesi uzun metin ve dar kutuları bulmana yardımcı olur.',
            'Select text on the slide to edit it. Move and resize its box. Check readability in the text panel to find long passages and tight boxes.')
      ),
      (
        Icons.view_in_ar_outlined,
        tr('Konuna uygun modeli bul', 'Find a relevant model'),
        tr('3D Modeller panelinde isim, etiket veya kategori ara. Slayta uygun önerilerin gerekçesini bilgi simgesinden gör. Benzerlerini göster düğmesi yeni modelleri keşfetmeni sağlar; kartı seçtiğinde model slayta eklenir.',
            'Search names, tags or categories in 3D Models. See suggestion evidence using the info icon. Show similar models helps you explore; select a card to add it to the slide.')
      ),
      (
        Icons.speed_rounded,
        tr('Görünümü ve hareketi ayarla', 'Tune appearance and motion'),
        tr('Arka planı anlatımına göre seç. Görüntü kalitesi ayarındaki Tasarruf görünümü daha hafif model ve efektleri kullanır. Hareket dikkat dağıtıyorsa animasyonları azalt; kamera açısını önizlemede de kontrol et.',
            'Choose a background that supports your story. Economy quality uses lighter models and effects. Reduce distracting motion and check the camera angle in preview.')
      ),
      (
        Icons.slideshow_rounded,
        tr('Kontrol et, kaydet ve paylaş', 'Review, save and share'),
        tr('Sunum Modu ile slaytları sırayla izle. Projeyi Kaydet düzenlenebilir bir yedek oluşturur. Dışa Aktar menüsünden HTML veya PDF seç; paylaşmadan önce dışa aktarılan dosyayı açıp kontrol et.',
            'Use Presentation Mode to review slides in order. Save Project creates an editable backup. Export HTML or PDF, then open and check the exported file before sharing.')
      ),
    ];
    final step = steps[_step];
    return AlertDialog(
      title: Text(tr('Hızlı başlangıç', 'Quick start')),
      content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_step + 1} / ${steps.length}',
                  semanticsLabel: tr(
                      'Adım ${_step + 1}, toplam ${steps.length}',
                      'Step ${_step + 1} of ${steps.length}')),
              const SizedBox(height: 12),
              Icon(step.$1,
                  size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(step.$2, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(step.$3),
            ],
          ))),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tr('Kapat', 'Close'))),
        if (_step > 0)
          TextButton(
              onPressed: () => setState(() => _step--),
              child: Text(tr('Önceki', 'Previous'))),
        FilledButton(
            onPressed: () {
              if (_step == steps.length - 1) {
                Navigator.of(context).pop();
              } else {
                setState(() => _step++);
              }
            },
            child: Text(_step == steps.length - 1
                ? tr('Tamam', 'Done')
                : tr('Sonraki', 'Next'))),
      ],
    );
  }
}
