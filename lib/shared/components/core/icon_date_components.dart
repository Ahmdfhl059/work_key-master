part of '../components.dart';

class DefaultIconButton extends StatefulWidget {
  final Function onPressed;
  final Widget icon;
  final double size;
  final dynamic color;

  const DefaultIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 35,
    this.color,
  });

  @override
  State<DefaultIconButton> createState() => _DefaultIconButtonState();
}

class _DefaultIconButtonState extends State<DefaultIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.onPressed();
        });
      },
      icon: widget.icon,
      style: ButtonStyle(
        iconSize: WidgetStatePropertyAll(widget.size),
        iconColor: WidgetStatePropertyAll(widget.color),
      ),
    );
  }
}

class DatePicked extends StatefulWidget {
  const DatePicked({super.key});

  @override
  State<DatePicked> createState() => _DatePickedState();
}

String selectDate = '';

class _DatePickedState extends State<DatePicked> {
  DateTime datePicked = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      radius: 15,
      onTap: () async {
        datePicked = (await DatePicker.showSimpleDatePicker(
          context,
          backgroundColor: Theme.of(context).datePickerTheme.backgroundColor,
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
          pickerMode: DateTimePickerMode.date,
          dateFormat: "yyyy-MM-dd",
          locale: DateTimePickerLocale.en_us,
          looping: false,
          titleText: 'Select_Date',
          cancelText: 'Cancel',
          confirmText: 'Ok',
          textColor: Theme.of(context).datePickerTheme.dividerColor,
        ))!;
        print(selectDate);
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.fromBorderSide(BorderSide(color: primary)),
        ),
        child: DefaultText(
          text: selectDate.isEmpty ? 'birthday' : selectDate.toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
