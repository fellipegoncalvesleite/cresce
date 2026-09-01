import '../models/age_range.dart';
import '../models/baby_message.dart';

const List<BabyMessage> babyMessages = [
  BabyMessage(
    id: 'generic_world',
    text: 'Tem um mundo inteiro ficando interessante.',
  ),
  BabyMessage(
    id: 'generic_small_moves',
    text: 'Pequenos movimentos, grandes descobertas.',
  ),
  BabyMessage(id: 'generic_lap', text: 'Colo também faz parte da descoberta.'),
  BabyMessage(
    id: 'generic_rhythm',
    text: 'Cada bebê encontra seu próprio ritmo.',
  ),
  BabyMessage(
    id: '0_3_close',
    text: 'Tudo é novo quando o mundo ainda cabe bem pertinho.',
    ageRange: AgeRange(minMonths: 0, maxMonths: 3),
  ),
  BabyMessage(
    id: '3_6_reach',
    text: 'Mãos curiosas começam a encontrar cada vez mais coisas.',
    ageRange: AgeRange(minMonths: 3, maxMonths: 6),
  ),
  BabyMessage(
    id: '6_9_discovery',
    text: 'Uma fase cheia de alcance, movimento e descoberta.',
    ageRange: AgeRange(minMonths: 6, maxMonths: 9),
  ),
  BabyMessage(
    id: '9_12_corners',
    text: 'Cada cantinho parece guardar uma novidade.',
    ageRange: AgeRange(minMonths: 9, maxMonths: 12),
  ),
  BabyMessage(
    id: '12_18_steps',
    text: 'O dia fica maior quando dá para participar de mais coisas.',
    ageRange: AgeRange(minMonths: 12, maxMonths: 18),
  ),
  BabyMessage(
    id: '18_24_words',
    text: 'Gestos, palavras e ideias começam a ocupar mais espaço.',
    ageRange: AgeRange(minMonths: 18, maxMonths: 24),
  ),
  BabyMessage(
    id: '24_36_imagination',
    text: 'Um objeto simples pode virar quase qualquer coisa.',
    ageRange: AgeRange(minMonths: 24, maxMonths: 36),
  ),
  BabyMessage(
    id: '36_48_stories',
    text: 'As descobertas agora também viram histórias.',
    ageRange: AgeRange(minMonths: 36, maxMonths: 48),
  ),
];

BabyMessage messageForDay({required DateTime date, int? ageMonths}) {
  final candidates = babyMessages.where((message) {
    final range = message.ageRange;
    if (range == null) return true;
    return ageMonths != null && range.contains(ageMonths);
  }).toList();

  final seed =
      date.year * 10000 + date.month * 100 + date.day + (ageMonths ?? 0) * 37;
  return candidates[seed % candidates.length];
}
