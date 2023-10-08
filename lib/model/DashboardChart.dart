class DashboardData {
  final int totalVal;
  final String colorVal;
  final String titleVal;

  DashboardData(this.totalVal, this.colorVal, this.titleVal);

  DashboardData.fromMap(Map<String, dynamic> map)
      : assert(map['total'] != null),
        assert(map['color'] != null),
        assert(map['title'] != null),
        totalVal = map['total'],
        colorVal = map['color'],
        titleVal = map['title'];

  @override
  String toString() => "Record<$totalVal: $colorVal: $titleVal>";
}
