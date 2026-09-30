/// Tile-map level definitions for Super Dash.
///
/// Each level is a list of equal-length strings. Every character is one tile.
/// The map is read top-to-bottom, so the last row is the ground.
///
/// Legend:
///   ' ' empty / sky
///   'X' solid ground block
///   'B' breakable brick
///   '?' question block (awards a coin)
///   'o' floating coin
///   'P' pipe body (solid)
///   'p' pipe top (solid, slightly wider look)
///   'G' Goomba enemy spawn
///   'S' player start
///   'F' flag pole (level goal)
class LevelData {
  const LevelData({
    required this.name,
    required this.rows,
    required this.timeLimit,
  });

  final String name;
  final List<String> rows;
  final int timeLimit; // seconds

  int get columns => rows.isEmpty ? 0 : rows.first.length;
  int get rowCount => rows.length;
}

class Levels {
  Levels._();

  static const List<LevelData> all = <LevelData>[
    LevelData(
      name: 'World 1-1  •  Green Hills',
      timeLimit: 120,
      rows: <String>[
        '                                                                        ',
        '                                                                        ',
        '            o o o                                                       ',
        '                        ?                          o o o                ',
        '                                                                        ',
        '        ?  B?B          B B B          ?                    B B         ',
        '                                                                    F   ',
        '                              o o           G           p           X   ',
        '                    G        B B B         ppp         PP   G       X   ',
        'S              G            X   X   X      PPPP        PPP          XX   ',
        'XXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXX   XXXXXXXXXXXXXXXXXXX   ',
        'XXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXX   XXXXXXXXXXXXXXXXXXX   ',
      ],
    ),
    LevelData(
      name: 'World 1-2  •  Brick Caverns',
      timeLimit: 130,
      rows: <String>[
        '                                                                            ',
        '        o o o o                              o o o                          ',
        '     B B B B B B          ? ? ?           B B B B B                         ',
        '                                                                            ',
        '                    G           G                          o o o           ',
        '            p              B B B              p         B B B B B      F    ',
        '           ppp            B   B B            ppp                       X    ',
        '   ?      PPPP     G     B     B      G      PPPP    G      G          XX    ',
        'S        PPPPP         X X X X X X          PPPPP        p            XXX    ',
        'XXXXXX   XXXXX   XXXXXXXXXXXXXXXXXXXX   XXXXXXXXXX   XXXXXXpppXXXXXXXXXXXX    ',
        'XXXXXX   XXXXX   XXXXXXXXXXXXXXXXXXXX   XXXXXXXXXX   XXXXXXPPPXXXXXXXXXXXX    ',
        'XXXXXX   XXXXX   XXXXXXXXXXXXXXXXXXXX   XXXXXXXXXX   XXXXXXPPPXXXXXXXXXXXX    ',
      ],
    ),
    LevelData(
      name: 'World 1-3  •  Sky Fortress',
      timeLimit: 140,
      rows: <String>[
        '                                                                                ',
        '          o o o                    o o o                     o o o              ',
        '       B B ? B B                 B B ? B B                 B B ? B B             ',
        '                     G                        G                                 ',
        '                    XXXX          G          XXXX        G                 F    ',
        '            o             G              o                          o     X     ',
        '           XXXX     B B B XXXX          XXXX    B B B    G          XX    XX     ',
        '   G                                                              XXX          ',
        '  XXX      G         p          G           p            G       XXXX    G      ',
        'S        XXXXX      ppp   G    XXXXX       ppp    G     XXXXX             XXXX   ',
        'XXXX   XXXXXXXX   XXPPPXXXXXXXXXXXXXXX   XXPPPXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXX   ',
        'XXXX   XXXXXXXX   XXPPPXXXXXXXXXXXXXXX   XXPPPXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXX   ',
      ],
    ),
  ];

  static int get count => all.length;
}
