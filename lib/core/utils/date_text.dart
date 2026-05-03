const _shortMonths = [
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

const _longMonths = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String formatShortDate(DateTime date) {
  return '${date.day} ${_shortMonths[date.month - 1]}';
}

String formatReadableDate(DateTime date) {
  return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
}

String formatMonthYear(DateTime date) {
  return '${_longMonths[date.month - 1]} ${date.year}';
}
