class PlanTierService {
  const PlanTierService._();

  static const String free = 'free';
  static const String plus = 'plus';

  /// Eski veritabanı değerleri erişim kaybetmeden tek ücretli plana taşınır.
  static bool isPlus(String tier) =>
      tier == plus || tier == 'premium' || tier == 'pro';

  static String normalize(String tier) => isPlus(tier) ? plus : free;

  static bool isSupportedPromoGrant(String grantsTier) => isPlus(grantsTier);

  static bool canRedeemPlus({
    required String grantsTier,
    required String currentTier,
  }) =>
      isSupportedPromoGrant(grantsTier) && !isPlus(currentTier);
}
