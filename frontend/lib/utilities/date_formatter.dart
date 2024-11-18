
String formatDate(String dateString) {
  // 원래 문자열을 DateTime으로 변환
  DateTime dateTime = DateTime.parse(dateString);

  // 오후/오전을 판단하여 'a' 값을 구하기
  String period = (dateTime.hour >= 12) ? '오후' : '오전';

  // 12시간제 시간으로 변환
  int hour = dateTime.hour % 12;
  if (hour == 0) hour = 12; // 12시를 12로 표시하도록 처리

  // 2자리 수로 분을 포맷
  String minute = dateTime.minute.toString().padLeft(2, '0');

  // 날짜 형식 'yyyy/MM/dd a hh:mm'로 변환
  String formattedDate = "${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} $period $hour:$minute";

  return formattedDate;
}