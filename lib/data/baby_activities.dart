import '../models/age_range.dart';
import '../models/baby_activity.dart';

const List<BabyActivity> genericBabyActivities = [
  BabyActivity(
    id: 'generic_talk_together',
    title: 'Conversa de pertinho',
    description:
        'Um momento curto de conversa, pausa e resposta junto do bebê.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
    category: BabyActivityCategory.social,
    durationMinutes: 5,
    instructions: [
      'Fique perto e diga o nome de algo que vocês estejam vendo.',
      'Faça uma pausa para perceber sons, gestos ou olhares.',
      'Responda com calma e continue a conversa no ritmo da criança.',
    ],
  ),
  BabyActivity(
    id: 'generic_song_routine',
    title: 'Cantiga na rotina',
    description: 'Transforme um momento comum do dia em uma cantiga tranquila.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
    category: BabyActivityCategory.calm,
    durationMinutes: 4,
    instructions: [
      'Escolha uma cantiga curta que você conheça.',
      'Cante devagar durante a troca, o colo ou a organização dos brinquedos.',
      'Pare quando a criança perder o interesse; não é preciso terminar.',
    ],
  ),
  BabyActivity(
    id: 'generic_book_together',
    title: 'Livro juntos',
    description:
        'Folheiem um livro curto e conversem sobre o que chama atenção.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
    category: BabyActivityCategory.language,
    durationMinutes: 6,
    instructions: [
      'Escolha um livro resistente e adequado à idade.',
      'Aponte uma imagem por vez e nomeie o que aparece.',
      'Deixe a criança tocar, apontar ou virar páginas quando quiser.',
    ],
  ),
];

const List<BabyActivity> ageAwareBabyActivities = [
  BabyActivity(
    id: '0_3_faces',
    title: 'Rostos e vozes',
    description:
        'Ideia para esta fase: conversar de perto com expressões suaves.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 3),
    category: BabyActivityCategory.social,
    durationMinutes: 3,
    instructions: [
      'Apoie o bebê com conforto e fique a uma distância em que ele veja seu rosto.',
      'Fale devagar e alterne entre um sorriso e uma expressão neutra.',
      'Faça pausas e acompanhe o interesse do bebê.',
    ],
  ),
  BabyActivity(
    id: '0_3_tummy_together',
    title: 'Barriga para baixo acompanhado',
    description:
        'Alguns minutos acordado no chão podem virar brincadeira junto.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 3),
    category: BabyActivityCategory.movement,
    durationMinutes: 3,
    instructions: [
      'Escolha uma superfície firme e segura enquanto o bebê estiver acordado.',
      'Fique no chão na mesma altura, sempre acompanhando de perto.',
      'Encerre ao primeiro sinal de desconforto ou cansaço.',
    ],
  ),
  BabyActivity(
    id: '0_3_real_tracking',
    title: 'Acompanhar um objeto real',
    description:
        'Um objeto simples pode ser interessante quando se move bem devagar.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 3),
    category: BabyActivityCategory.sensory,
    durationMinutes: 2,
    instructions: [
      'Escolha um objeto seguro e de contraste fácil de perceber.',
      'Mova-o lentamente de um lado para o outro, sem aproximar demais do rosto.',
      'Pare se o bebê desviar o olhar ou parecer cansado.',
    ],
  ),
  BabyActivity(
    id: '3_6_reach_toy',
    title: 'Alcançar o brinquedo',
    description:
        'Experimente oferecer um brinquedo seguro a uma pequena distância.',
    ageRange: AgeRange(minMonths: 3, maxMonths: 6),
    category: BabyActivityCategory.movement,
    durationMinutes: 5,
    instructions: [
      'Coloque o bebê em uma posição confortável e acompanhada.',
      'Mostre um brinquedo leve e seguro ao alcance das mãos.',
      'Dê tempo para explorar sem puxar a mão da criança até o objeto.',
    ],
  ),
  BabyActivity(
    id: '3_6_safe_textures',
    title: 'Texturas seguras',
    description:
        'Tecidos e objetos cotidianos podem oferecer sensações diferentes.',
    ageRange: AgeRange(minMonths: 3, maxMonths: 6),
    category: BabyActivityCategory.sensory,
    durationMinutes: 5,
    instructions: [
      'Separe dois ou três materiais grandes, limpos e sem peças soltas.',
      'Encoste cada textura nas mãos enquanto nomeia: macio, liso, enrugado.',
      'Deixe o bebê explorar sob supervisão constante.',
    ],
  ),
  BabyActivity(
    id: '3_6_copy_sounds',
    title: 'Imitar sons',
    description: 'Trocar sons simples pode ser divertido nesta fase.',
    ageRange: AgeRange(minMonths: 3, maxMonths: 6),
    category: BabyActivityCategory.language,
    durationMinutes: 4,
    instructions: [
      'Escute um som ou balbucio do bebê.',
      'Repita algo parecido de forma calma e espere.',
      'Alterne como uma conversa, sem exigir uma resposta.',
    ],
  ),
  BabyActivity(
    id: 'peekaboo_together',
    title: 'Cadê? Achou!',
    description:
        'Uma brincadeira curta de esconder e revelar para fazer junto.',
    ageRange: AgeRange(minMonths: 6, maxMonths: 18),
    category: BabyActivityCategory.play,
    durationMinutes: 3,
    instructions: [
      'Diga “cadê?” enquanto o objeto estiver escondido.',
      'Toque na tela junto para revelar e diga “achou!”.',
      'Faça poucas repetições e depois continue a brincadeira fora da tela.',
    ],
    experience: BabyActivityExperience.peekaboo,
  ),
  BabyActivity(
    id: '6_9_partial_hide',
    title: 'Brinquedo meio escondido',
    description: 'Experimente deixar parte de um brinquedo conhecido visível.',
    ageRange: AgeRange(minMonths: 6, maxMonths: 9),
    category: BabyActivityCategory.play,
    durationMinutes: 5,
    instructions: [
      'Escolha um brinquedo grande e seguro que a criança já conheça.',
      'Cubra apenas uma parte dele com um pano leve.',
      'Espere a iniciativa da criança e comemore a descoberta com palavras.',
    ],
  ),
  BabyActivity(
    id: 'animal_sounds_together',
    title: 'Sons dos bichinhos',
    description: 'Ouçam alguns sons reais e imitem os bichos juntos.',
    ageRange: AgeRange(minMonths: 6, maxMonths: 24),
    category: BabyActivityCategory.language,
    durationMinutes: 4,
    instructions: [
      'Escolham um bicho por vez.',
      'Toque o som uma vez e diga o nome do animal.',
      'Imitem juntos e parem antes de a brincadeira ficar repetitiva.',
    ],
    experience: BabyActivityExperience.animalSounds,
  ),
  BabyActivity(
    id: '9_12_container',
    title: 'Colocar e tirar do pote',
    description: 'Objetos grandes e um recipiente simples rendem exploração.',
    ageRange: AgeRange(minMonths: 9, maxMonths: 12),
    category: BabyActivityCategory.play,
    durationMinutes: 7,
    instructions: [
      'Use um pote sem tampa e objetos grandes que não ofereçam risco de engasgo.',
      'Mostre uma vez como colocar um objeto e retirar.',
      'Entregue o pote e deixe a criança experimentar acompanhada.',
    ],
  ),
  BabyActivity(
    id: '9_12_gestures',
    title: 'Gestos juntos',
    description: 'Palmas, tchau e beijo podem virar uma troca divertida.',
    ageRange: AgeRange(minMonths: 9, maxMonths: 12),
    category: BabyActivityCategory.social,
    durationMinutes: 4,
    instructions: [
      'Escolha um gesto simples e faça devagar.',
      'Nomeie o gesto, como “tchau”, e espere.',
      'Aceite qualquer tentativa sem corrigir a criança.',
    ],
  ),
  BabyActivity(
    id: '9_12_roll_ball',
    title: 'Rolar a bola',
    description: 'Uma bola grande pode ir e voltar entre vocês.',
    ageRange: AgeRange(minMonths: 9, maxMonths: 12),
    category: BabyActivityCategory.movement,
    durationMinutes: 6,
    instructions: [
      'Sentem-se próximos no chão com uma bola macia e grande.',
      'Role a bola lentamente em direção à criança.',
      'Ajude apenas o necessário para ela empurrar a bola de volta.',
    ],
  ),
  BabyActivity(
    id: '12_18_two_choices',
    title: 'Duas escolhas',
    description: 'Escolher entre duas opções simples pode ser divertido.',
    ageRange: AgeRange(minMonths: 12, maxMonths: 18),
    category: BabyActivityCategory.social,
    durationMinutes: 4,
    instructions: [
      'Mostre dois brinquedos ou livros conhecidos.',
      'Pergunte qual a criança quer e dê tempo para apontar, olhar ou pegar.',
      'Nomeie a escolha sem exigir que ela fale.',
    ],
  ),
  BabyActivity(
    id: '12_18_stack_big',
    title: 'Empilhar peças grandes',
    description: 'Blocos grandes permitem montar, derrubar e tentar de novo.',
    ageRange: AgeRange(minMonths: 12, maxMonths: 18),
    category: BabyActivityCategory.play,
    durationMinutes: 8,
    instructions: [
      'Separe poucas peças grandes e estáveis.',
      'Monte uma torre pequena como convite.',
      'Deixe a criança empilhar ou derrubar sem transformar em tarefa.',
    ],
  ),
  BabyActivity(
    id: '12_18_body_names',
    title: 'Onde está?',
    description:
        'Nomear partes do corpo durante a rotina vira uma brincadeira simples.',
    ageRange: AgeRange(minMonths: 12, maxMonths: 18),
    category: BabyActivityCategory.language,
    durationMinutes: 4,
    instructions: [
      'Pergunte “onde está a mão?” e mostre a sua.',
      'Nomeie duas ou três partes do corpo sem testar a criança.',
      'Repita em outro momento do dia se houver interesse.',
    ],
  ),
  BabyActivity(
    id: '18_24_simple_pretend',
    title: 'Faz de conta simples',
    description:
        'Um objeto conhecido pode entrar em uma pequena cena imaginária.',
    ageRange: AgeRange(minMonths: 18, maxMonths: 24),
    category: BabyActivityCategory.play,
    durationMinutes: 8,
    instructions: [
      'Use uma boneca, bichinho ou objeto seguro já conhecido.',
      'Faça uma ação curta, como dar água de mentirinha.',
      'Convide a criança a continuar do jeito que quiser.',
    ],
  ),
  BabyActivity(
    id: '18_24_tidy_together',
    title: 'Guardar juntos',
    description:
        'Organizar poucos brinquedos pode virar participação na rotina.',
    ageRange: AgeRange(minMonths: 18, maxMonths: 24),
    category: BabyActivityCategory.social,
    durationMinutes: 5,
    instructions: [
      'Escolha apenas três ou quatro brinquedos no chão.',
      'Mostre onde um deles fica e convide a criança a levar outro.',
      'Agradeça a ajuda sem cobrar que tudo seja guardado.',
    ],
  ),
  BabyActivity(
    id: '18_24_music_moves',
    title: 'Movimentos com música',
    description: 'Uma cantiga conhecida pode acompanhar movimentos calmos.',
    ageRange: AgeRange(minMonths: 18, maxMonths: 24),
    category: BabyActivityCategory.movement,
    durationMinutes: 6,
    instructions: [
      'Escolha uma música curta e conhecida.',
      'Balance os braços, bata palmas ou caminhe devagar junto.',
      'Deixe a criança inventar um movimento para você imitar.',
    ],
  ),
  BabyActivity(
    id: '24_36_sort_objects',
    title: 'Separar e juntar',
    description:
        'Poucos objetos podem ser agrupados por uma característica simples.',
    ageRange: AgeRange(minMonths: 24, maxMonths: 36),
    category: BabyActivityCategory.play,
    durationMinutes: 8,
    instructions: [
      'Separe objetos grandes de duas cores ou dois tipos bem diferentes.',
      'Faça um grupo como exemplo sem transformar em prova.',
      'Conversem sobre o que ficou parecido ou diferente.',
    ],
  ),
  BabyActivity(
    id: '24_36_participatory_story',
    title: 'História com participação',
    description: 'Uma história curta ganha perguntas abertas e gestos.',
    ageRange: AgeRange(minMonths: 24, maxMonths: 36),
    category: BabyActivityCategory.language,
    durationMinutes: 8,
    instructions: [
      'Escolha uma história curta ou uma sequência de figuras.',
      'Pare em uma imagem e pergunte o que a criança percebe.',
      'Aceite palavras, gestos e invenções como parte da história.',
    ],
  ),
  BabyActivity(
    id: 'shapes_together',
    title: 'Encontre a forma',
    description:
        'Uma escolha visual simples para nomear formas e cores juntos.',
    ageRange: AgeRange(minMonths: 24, maxMonths: 48),
    category: BabyActivityCategory.play,
    durationMinutes: 4,
    instructions: [
      'Leia a forma pedida em voz alta.',
      'Deixe a criança tocar uma das opções grandes.',
      'Depois procurem objetos com uma forma parecida fora da tela.',
    ],
    experience: BabyActivityExperience.shapes,
  ),
  BabyActivity(
    id: '36_48_story_together',
    title: 'Inventar uma história',
    description: 'Três objetos podem virar começo, meio e fim de uma história.',
    ageRange: AgeRange(minMonths: 36, maxMonths: 48),
    category: BabyActivityCategory.language,
    durationMinutes: 10,
    instructions: [
      'Escolham três brinquedos ou objetos seguros.',
      'Comece com uma frase curta sobre o primeiro.',
      'Convide a criança a decidir o que acontece depois e acompanhe a ideia.',
    ],
  ),
  BabyActivity(
    id: '36_48_match_real',
    title: 'Pares da casa',
    description: 'Procurem objetos que combinam por uso, forma ou categoria.',
    ageRange: AgeRange(minMonths: 36, maxMonths: 48),
    category: BabyActivityCategory.play,
    durationMinutes: 8,
    instructions: [
      'Escolha um objeto seguro, como uma meia ou uma colher.',
      'Procurem juntos outro que combine com ele de algum jeito.',
      'Conversem sobre o motivo da associação; mais de uma resposta pode funcionar.',
    ],
  ),
  BabyActivity(
    id: '36_48_guided_movement',
    title: 'Caminho de movimentos',
    description:
        'Uma sequência curta de movimentos para fazer no próprio ritmo.',
    ageRange: AgeRange(minMonths: 36, maxMonths: 48),
    category: BabyActivityCategory.movement,
    durationMinutes: 7,
    instructions: [
      'Abra um espaço seguro e combine três movimentos simples.',
      'Façam juntos: dois passos, um agachamento leve e braços para cima.',
      'Troquem a ordem ou deixem a criança inventar a próxima sequência.',
    ],
  ),
];

const List<BabyActivity> babyActivities = [
  ...genericBabyActivities,
  ...ageAwareBabyActivities,
];
