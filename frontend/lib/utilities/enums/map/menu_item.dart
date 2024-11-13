enum MenuItem {
  viewHiddenStars('내가 숨긴 별 보기'),
  viewStarsForEveryone('모두에게 별 보기'),
  viewStarsForMe('나에게만 별 보기');

  final String displayText;
  const MenuItem(this.displayText);
}
