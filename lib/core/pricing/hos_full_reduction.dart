/// 满减阶梯规则（后台配置）。
class SHOFullReductionTier {
  const SHOFullReductionTier({
    required this.minOrderCents,
    required this.reductionCents,
    this.label = '',
  });

  final int minOrderCents;
  final int reductionCents;
  final String label;

  factory SHOFullReductionTier.fromJson(Map<String, dynamic> json) {
    return SHOFullReductionTier(
      minOrderCents: json['minOrderCents'] as int? ?? 0,
      reductionCents: json['reductionCents'] as int? ?? 0,
      label: json['label'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'minOrderCents': minOrderCents,
    'reductionCents': reductionCents,
    if (label.isNotEmpty) 'label': label,
  };
}

/// 抢购结算活动上下文（单商品行）。
class SHOCheckoutActivityLine {
  const SHOCheckoutActivityLine({
    required this.productId,
    required this.sessionId,
    required this.unitPriceCents,
    this.originalUnitPriceCents = 0,
    this.fullReductionTiers = const [],
  });

  final String productId;
  final String sessionId;
  final int unitPriceCents;
  final int originalUnitPriceCents;
  final List<SHOFullReductionTier> fullReductionTiers;

  factory SHOCheckoutActivityLine.fromJson(Map<String, dynamic> json) {
    final tiers =
        (json['fullReductionTiers'] as List<dynamic>?)
            ?.whereType<Map<String, dynamic>>()
            .map(SHOFullReductionTier.fromJson)
            .toList() ??
        const <SHOFullReductionTier>[];
    return SHOCheckoutActivityLine(
      productId: json['productId'] as String,
      sessionId: json['sessionId'] as String? ?? '',
      unitPriceCents: json['unitPriceCents'] as int? ?? 0,
      originalUnitPriceCents: json['originalUnitPriceCents'] as int? ?? 0,
      fullReductionTiers: tiers,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'sessionId': sessionId,
    'unitPriceCents': unitPriceCents,
    'originalUnitPriceCents': originalUnitPriceCents,
    'fullReductionTiers': fullReductionTiers.map((t) => t.toJson()).toList(),
  };
}

extension SHOFullReductionCalculator on List<SHOFullReductionTier> {
  /// 取当前小计可享的最高满减档。
  int bestReductionFor(int subtotalCents) {
    var best = 0;
    for (final tier in this) {
      if (subtotalCents >= tier.minOrderCents && tier.reductionCents > best) {
        best = tier.reductionCents;
      }
    }
    return best;
  }

  SHOFullReductionTier? bestTierFor(int subtotalCents) {
    SHOFullReductionTier? picked;
    for (final tier in this) {
      if (subtotalCents >= tier.minOrderCents &&
          (picked == null || tier.reductionCents > picked.reductionCents)) {
        picked = tier;
      }
    }
    return picked;
  }
}

/// 汇总活动行附带的满减阶梯。
List<SHOFullReductionTier> collectActivityFullReductionTiers(
  Map<String, SHOCheckoutActivityLine> lines,
) {
  final all = <SHOFullReductionTier>[];
  for (final line in lines.values) {
    all.addAll(line.fullReductionTiers);
  }
  return all;
}
