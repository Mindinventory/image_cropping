part of image_cropping;

/// [AppButton] class is use to show button in image screen.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.icon,
    required this.background,
    required this.onPress,
    this.margin = 20,
    this.size = 17,
    this.iconColor = Colors.white,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final Color background;
  final Function() onPress;
  final double margin;
  final double size;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(shape: BoxShape.circle, color: background),
        child: Icon(
          icon,
          color: iconColor,
          size: size,
        ),
      ),
    );
  }
}
