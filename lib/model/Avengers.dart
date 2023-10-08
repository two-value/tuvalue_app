class Avengers {
  String name;
  String weapon;
  Avengers({this.name, this.weapon});

  static List getAvengers() {
    return <Avengers>[
      Avengers(name: "Captain America", weapon: "Shield"),
      Avengers(name: "Thorn", weapon: "Mjolnir"),
      Avengers(name: "Spiderman", weapon: "Neb Shooters"),
      Avengers(name: "Doctor Strange", weapon: "Eye Of Agamotto"),
    ];
  }
}
