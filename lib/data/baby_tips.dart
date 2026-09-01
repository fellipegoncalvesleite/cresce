import '../models/age_range.dart';
import '../models/baby_tip.dart';

const List<BabyTip> genericBabyTips = [
  BabyTip(
    id: 'generic_talk',
    text: 'Converse durante a rotina e responda aos sons e gestos do bebê.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
    category: 'conexão',
  ),
  BabyTip(
    id: 'generic_floor',
    text:
        'Reserve um espaço seguro no chão para explorar movimentos no próprio ritmo.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
    category: 'movimento',
  ),
  BabyTip(
    id: 'generic_read',
    text:
        'Livros curtos, imagens simples e repetição podem virar um momento gostoso juntos.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 48),
    category: 'linguagem',
  ),
];

const List<BabyTip> ageAwareBabyTips = [
  BabyTip(
    id: '0_3_faces',
    text: 'Aproxime o rosto e varie expressões enquanto conversa com calma.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 3),
    category: 'conexão',
  ),
  BabyTip(
    id: '0_3_tummy',
    text:
        'Pequenos momentos acordado de barriga para baixo podem virar brincadeira acompanhada.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 3),
    category: 'movimento',
  ),
  BabyTip(
    id: '3_6_reach',
    text:
        'Ofereça objetos leves e seguros a uma pequena distância para convidar a alcançar.',
    ageRange: AgeRange(minMonths: 3, maxMonths: 6),
    category: 'movimento',
  ),
  BabyTip(
    id: '3_6_sounds',
    text: 'Conversar e repetir sons ajuda a tornar a linguagem familiar.',
    ageRange: AgeRange(minMonths: 3, maxMonths: 6),
    category: 'linguagem',
  ),
  BabyTip(
    id: '6_9_search',
    text:
        'Deixe objetos seguros um pouco fora do alcance para transformar a procura em brincadeira.',
    ageRange: AgeRange(minMonths: 6, maxMonths: 9),
    category: 'movimento',
  ),
  BabyTip(
    id: '6_9_peekaboo',
    text:
        'Brincadeiras de aparecer e desaparecer podem ser divertidas nesta fase.',
    ageRange: AgeRange(minMonths: 6, maxMonths: 9),
    category: 'brincadeira',
  ),
  BabyTip(
    id: '9_12_container',
    text:
        'Potes grandes e objetos seguros para colocar e tirar rendem explorações simples.',
    ageRange: AgeRange(minMonths: 9, maxMonths: 12),
    category: 'brincadeira',
  ),
  BabyTip(
    id: '9_12_names',
    text: 'Nomeie pessoas e objetos que chamam atenção durante o dia.',
    ageRange: AgeRange(minMonths: 9, maxMonths: 12),
    category: 'linguagem',
  ),
  BabyTip(
    id: '12_18_choices',
    text:
        'Ofereça duas opções simples, como escolher entre dois brinquedos ou livros.',
    ageRange: AgeRange(minMonths: 12, maxMonths: 18),
    category: 'autonomia',
  ),
  BabyTip(
    id: '12_18_copy',
    text:
        'Gestos fáceis de imitar, como bater palmas ou mandar beijo, podem virar brincadeira.',
    ageRange: AgeRange(minMonths: 12, maxMonths: 18),
    category: 'brincadeira',
  ),
  BabyTip(
    id: '18_24_words',
    text:
        'Acrescente uma palavra ao que a criança diz: “bola” pode virar “bola azul”.',
    ageRange: AgeRange(minMonths: 18, maxMonths: 24),
    category: 'linguagem',
  ),
  BabyTip(
    id: '18_24_help',
    text:
        'Convide para pequenas participações na rotina, como guardar um brinquedo.',
    ageRange: AgeRange(minMonths: 18, maxMonths: 24),
    category: 'autonomia',
  ),
  BabyTip(
    id: '24_36_pretend',
    text:
        'Brincadeiras de faz de conta simples podem partir de objetos comuns e seguros.',
    ageRange: AgeRange(minMonths: 24, maxMonths: 36),
    category: 'imaginação',
  ),
  BabyTip(
    id: '24_36_story',
    text:
        'Pergunte o que aparece numa figura e aceite respostas do jeito que vierem.',
    ageRange: AgeRange(minMonths: 24, maxMonths: 36),
    category: 'linguagem',
  ),
  BabyTip(
    id: '36_48_sort',
    text:
        'Separar objetos por cor, tamanho ou tipo pode virar uma brincadeira curta.',
    ageRange: AgeRange(minMonths: 36, maxMonths: 48),
    category: 'brincadeira',
  ),
  BabyTip(
    id: '36_48_storytelling',
    text:
        'Inventem juntos histórias curtas a partir de uma imagem ou brinquedo favorito.',
    ageRange: AgeRange(minMonths: 36, maxMonths: 48),
    category: 'linguagem',
  ),
];

const List<BabyTip> babyTips = [...genericBabyTips, ...ageAwareBabyTips];

List<BabyTip> tipsForAge(int? ageMonths) {
  if (ageMonths == null) return genericBabyTips;
  return babyTips.where((tip) => tip.ageRange.contains(ageMonths)).toList();
}
