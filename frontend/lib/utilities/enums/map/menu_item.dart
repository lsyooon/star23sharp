enum MenuItem {
  viewHiddenStars('보낸 보물 쪽지'),
  viewStarsForEveryone('단체 보물 쪽지'),
  viewStarsForMe('받은 보물 쪽지');

  final String displayText;
  const MenuItem(this.displayText);
}
