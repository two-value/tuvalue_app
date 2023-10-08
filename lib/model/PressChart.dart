class PressData {
  final int totalVal;
  final String colorVal;
  final String titleVal;

  PressData(this.totalVal, this.colorVal, this.titleVal);

  PressData.fromMap(Map<String, dynamic> map)
      : assert(map['total'] != null),
        assert(map['color'] != null),
        assert(map['title'] != null),
        totalVal = map['total'],
        colorVal = map['color'],
        titleVal = map['title'];

  @override
  String toString() => "Record<$totalVal: $colorVal: $titleVal>";
}
