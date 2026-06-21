/// مبلغِ پول به‌صورتِ **عددِ صحیحِ ریال** — هرگز float (ADR-0004).
///
/// تغییرناپذیر است؛ هیچ مبلغی در دامنه به‌صورتِ عددِ خام جابه‌جا نمی‌شود.
class Money {
  /// مقدار به ریال.
  final int rials;

  const Money(this.rials);
  const Money.zero() : rials = 0;

  /// ساخت از تومان (۱ تومان = ۱۰ ریال).
  factory Money.fromToman(int toman) => Money(toman * 10);

  /// مقدار به تومان (تقسیمِ صحیح).
  int get toman => rials ~/ 10;

  bool get isNegative => rials < 0;
  bool get isZero => rials == 0;

  Money operator +(Money other) => Money(rials + other.rials);
  Money operator -(Money other) => Money(rials - other.rials);
  Money operator *(int factor) => Money(rials * factor);
  Money operator -() => Money(-rials);

  @override
  bool operator ==(Object other) => other is Money && other.rials == rials;

  @override
  int get hashCode => rials.hashCode;

  @override
  String toString() => 'Money($rials rials)';
}
