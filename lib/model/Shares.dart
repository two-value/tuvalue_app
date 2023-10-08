class Shares {
  final int shareVal;
  final String colorVal;
  final String shareMonth;

  Shares(this.shareVal, this.colorVal, this.shareMonth);

  Shares.fromMap(Map<String, dynamic> map)
      : assert(map['total_shares'] != null),
        assert(map['color'] != null),
        assert(map['month'] != null),
        shareVal = map['total_shares'],
        colorVal = map['color'],
        shareMonth = map['month'];

  @override
  String toString() => "Record<$shareVal: $colorVal: $shareMonth>";
}
