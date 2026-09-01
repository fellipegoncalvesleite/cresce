import '../models/age_range.dart';
import '../models/media.dart';

/// Short animal recordings bundled only after source/license verification.
const List<AnimalSound> animalSounds = [
  AnimalSound(
    id: 'dog',
    name: 'Cachorro',
    emoji: '🐶',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/dog_bark.mp3',
    source: 'Wikimedia Commons — Ladrido perro.ogg',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Ladrido_perro.ogg',
    author: 'Edo.pt2',
    license: 'CC0 1.0',
    licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
    attributionRequired: false,
    modification: 'Transcodificação MP3 gerada pelo Wikimedia Commons.',
  ),
  AnimalSound(
    id: 'cat',
    name: 'Gato',
    emoji: '🐱',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/cat_meow.mp3',
    source: 'Wikimedia Commons — Meow.ogg',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Meow.ogg',
    author: 'Dan Crosby',
    license: 'CC BY-SA 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0/',
    attributionRequired: true,
    modification:
        'Transcodificação MP3 gerada pelo Wikimedia Commons; derivado sob CC BY-SA 3.0.',
  ),
  AnimalSound(
    id: 'cow',
    name: 'Vaca',
    emoji: '🐮',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/cow_moo.mp3',
    source: 'Wikimedia Commons — Mudchute cow 1.ogg',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Mudchute_cow_1.ogg',
    author: 'Secretlondon',
    license: 'CC BY-SA 3.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/3.0/',
    attributionRequired: true,
    modification:
        'Transcodificação MP3 gerada pelo Wikimedia Commons; derivado sob CC BY-SA 3.0.',
  ),
  AnimalSound(
    id: 'rooster',
    name: 'Galo',
    emoji: '🐔',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/rooster_crow.mp3',
    source: 'Wikimedia Commons — Medium rooster crowing.ogg / PDSounds #539',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Medium_rooster_crowing.ogg',
    author: 'alys',
    license: 'Domínio público',
    licenseUrl:
        'https://commons.wikimedia.org/wiki/File:Medium_rooster_crowing.ogg',
    attributionRequired: false,
    modification: 'Transcodificação MP3 gerada pelo Wikimedia Commons.',
  ),
  AnimalSound(
    id: 'sheep',
    name: 'Ovelha',
    emoji: '🐑',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/sheep_bleat.mp3',
    source: 'Wikimedia Commons — Sheep bleat.ogg',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Sheep_bleat.ogg',
    author: 'Eviatar Bach',
    license: 'CC0 1.0',
    licenseUrl: 'https://creativecommons.org/publicdomain/zero/1.0/',
    attributionRequired: false,
    modification: 'Transcodificação MP3 gerada pelo Wikimedia Commons.',
  ),
  AnimalSound(
    id: 'bird',
    name: 'Passarinho',
    emoji: '🐦',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/bird_chirp.mp3',
    source: 'Wikimedia Commons — Budgerigar chirping.ogg / PDSounds #506',
    sourceUrl:
        'https://commons.wikimedia.org/wiki/File:Budgerigar_chirping.ogg',
    author: 'mary905',
    license: 'Domínio público',
    licenseUrl:
        'https://commons.wikimedia.org/wiki/File:Budgerigar_chirping.ogg',
    attributionRequired: false,
    modification: 'Transcodificação MP3 gerada pelo Wikimedia Commons.',
  ),
  AnimalSound(
    id: 'frog',
    name: 'Sapo',
    emoji: '🐸',
    ageRange: AgeRange(minMonths: 4, maxMonths: 48),
    assetPath: 'audio/animals/frog_croak.mp3',
    source: 'Wikimedia Commons — Single Frog Croak.oga',
    sourceUrl: 'https://commons.wikimedia.org/wiki/File:Single_Frog_Croak.oga',
    author: 'MichaeltheFox8621',
    license: 'CC BY-SA 4.0',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
    attributionRequired: true,
    modification:
        'Transcodificação MP3 gerada pelo Wikimedia Commons; derivado sob CC BY-SA 4.0.',
  ),
];

/// Three original short stories written for Cresce (no famous characters).
/// Simple, repetitive, calming — suited for babies and toddlers.
const List<Story> stories = [
  Story(
    id: 'lua_soneca',
    title: 'A Lua que Queria uma Soneca',
    ageRange: AgeRange(minMonths: 0, maxMonths: 24),
    readingMinutes: 2,
    origin: 'História original Cresce',
    paragraphs: [
      'Era uma noite bem quietinha. A Lua subiu devagar, devagarinho, e bocejou: aaaah.',
      'Uma estrela piscou para ela. "Boa noite, Lua." A Lua sorriu e respondeu baixinho: "Boa noite, estrelinha."',
      'O vento passou macio, fazendo as folhas dizerem xiiii, xiiii, como quem pede silêncio.',
      'A Lua fechou um olho, depois o outro. E o céu inteiro ficou calminho, só esperando o sono chegar.',
      'Quando você fechar os olhos também, a Lua vai estar bem ali, cuidando do seu sono. Durma bem.',
    ],
  ),
  Story(
    id: 'pintinho_chuva',
    title: 'O Pintinho e a Gota de Chuva',
    ageRange: AgeRange(minMonths: 6, maxMonths: 36),
    readingMinutes: 2,
    origin: 'História original Cresce',
    paragraphs: [
      'Pinx era um pintinho amarelinho que nunca tinha visto a chuva.',
      'Plic! Uma gota caiu no seu biquinho. Plic, ploc! Caíram mais duas no chão.',
      '"Que barulho engraçado!", pensou Pinx, e saiu pulando: plic, ploc, plic, ploc.',
      'A galinha mamãe abriu a asa quentinha e chamou: "Vem, Pinx." E ele correu para baixo da asa.',
      'Lá de dentro, Pinx ouvia a chuva cantar plic-ploc lá fora, e foi ficando quentinho, quentinho, até dormir.',
    ],
  ),
  Story(
    id: 'caracol_devagar',
    title: 'O Caracol que Andava Devagar',
    ageRange: AgeRange(minMonths: 12, maxMonths: 48),
    readingMinutes: 3,
    origin: 'História original Cresce',
    paragraphs: [
      'Cacá, o caracol, andava bem devagar. Tão devagar que as formigas passavam por ele correndo.',
      '"Corre, Cacá!", diziam elas. Mas Cacá gostava de ir devagar, olhando cada folha pelo caminho.',
      'Ele viu uma flor cor-de-rosa. Parou. Cheirou. Sorriu.',
      'Ele viu uma poça d\'água brilhando. Parou. Olhou o céu lá dentro. Sorriu de novo.',
      'No fim do dia, Cacá chegou em casa devagarinho e disse: "Eu vi o dia inteiro." E foi dormir feliz.',
      'Às vezes, ir devagar é o jeito mais bonito de chegar.',
    ],
  ),
];

/// Traditional / public-domain Brazilian songs. We store only a title, a
/// suggested use, and a search query — never the full copyrighted-arrangement
/// lyrics.
const List<Song> songs = [
  Song(
    title: 'Nana Neném',
    moment: SongMoment.sleep,
    suggestion: 'Acalanto tradicional para embalar o sono.',
    searchQuery: 'Nana Neném cantiga de ninar tradicional',
    ageRange: AgeRange(minMonths: 0, maxMonths: 24),
  ),
  Song(
    title: 'Boi da Cara Preta',
    moment: SongMoment.sleep,
    suggestion: 'Cantiga de ninar bem conhecida para a hora de dormir.',
    searchQuery: 'Boi da Cara Preta cantiga de ninar',
    ageRange: AgeRange(minMonths: 0, maxMonths: 24),
  ),
  Song(
    title: 'Se Essa Rua Fosse Minha',
    moment: SongMoment.calm,
    suggestion: 'Melodia lenta, boa para acalmar no colo.',
    searchQuery: 'Se Essa Rua Fosse Minha cantiga tradicional',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
  ),
  Song(
    title: 'Borboletinha',
    moment: SongMoment.play,
    suggestion: 'Cantiga com gestos para brincar de imitar.',
    searchQuery: 'Borboletinha cantiga infantil tradicional',
    ageRange: AgeRange(minMonths: 6, maxMonths: 36),
  ),
  Song(
    title: 'Ciranda, Cirandinha',
    moment: SongMoment.play,
    suggestion: 'Roda cantada para brincar junto.',
    searchQuery: 'Ciranda Cirandinha cantiga de roda',
    ageRange: AgeRange(minMonths: 18, maxMonths: 48),
  ),
  Song(
    title: 'Peixe Vivo',
    moment: SongMoment.bath,
    suggestion: 'Cantiga leve, combina com a hora do banho.',
    searchQuery: 'Como Pode o Peixe Vivo cantiga tradicional',
    ageRange: AgeRange(minMonths: 6, maxMonths: 36),
  ),
];

/// External recommendations — each opens a search on YouTube/Spotify.
const List<ExternalMediaLink> externalRecommendations = [
  ExternalMediaLink(
    label: 'Músicas calmas para bebê',
    query: 'músicas calmas para bebê dormir',
    description: 'Playlists suaves para relaxar e embalar.',
  ),
  ExternalMediaLink(
    label: 'Ruído branco para sono',
    query: 'ruído branco para bebê dormir white noise',
    description: 'Som contínuo que ajuda alguns bebês a pegar no sono.',
  ),
  ExternalMediaLink(
    label: 'Sons da natureza',
    query: 'sons da natureza relaxante chuva mar',
    description: 'Chuva, mar e vento para um ambiente tranquilo.',
  ),
  ExternalMediaLink(
    label: 'Cantigas tradicionais infantis',
    query: 'cantigas tradicionais infantis domínio público',
    description: 'Clássicos de roda e de ninar para cantar junto.',
  ),
  ExternalMediaLink(
    label: 'Vídeos sem estímulo excessivo',
    query: 'vídeos calmos para bebê sem estímulo excessivo',
    description: 'Imagens lentas e cores suaves, com pouco estímulo.',
  ),
];
