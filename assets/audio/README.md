# Audio assets

The game loads these files at startup. They are **optional** — if a file is
missing the game simply runs silently (the `AudioManager` guards every call).

Drop short clips here with these exact names:

| File          | Suggested sound                    |
|---------------|------------------------------------|
| `jump.wav`    | short "boing" when the hero jumps  |
| `coin.wav`    | bright "ding" on coin pickup       |
| `stomp.wav`   | thud when an enemy is stomped      |
| `hurt.wav`    | descending tone when hit           |
| `levelup.wav` | fanfare on level complete          |
| `gameover.wav`| game-over jingle                   |
| `music.mp3`   | looping background music (BGM)     |

## Where to get free, license-friendly sounds

- https://freesound.org (filter by CC0)
- https://opengameart.org (many CC0 / CC-BY 8-bit packs)
- https://sfxr.me — generate retro 8-bit SFX in the browser and export as `.wav`

Keep SFX under ~1 second and mono for the snappiest response.

After adding files, they are already declared in `pubspec.yaml` under
`assets/audio/`, so just run `flutter pub get` and rebuild.
