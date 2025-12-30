import 'package:flutter/material.dart';

class PinDialog {
  static Future<bool> verify({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String expectedPin,
  }) async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PinDialogWidget(
        title: title,
        subtitle: subtitle,
        expectedPin: expectedPin,
        controller: controller,
      ),
    );

    controller.dispose();
    return result ?? false;
  }
}

class _PinDialogWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String expectedPin;
  final TextEditingController controller;

  _PinDialogWidget({
    required this.title,
    required this.subtitle,
    required this.expectedPin,
    required this.controller,
  });

  @override
  State<_PinDialogWidget> createState() => _PinDialogWidgetState();
}

class _PinDialogWidgetState extends State<_PinDialogWidget>
    with SingleTickerProviderStateMixin {
  final focusNode = FocusNode();

  bool isWrong = false;
  bool isLoading = false;

  late final AnimationController shakeCtrl;
  late final Animation<double> shake;

  @override
  void initState() {
    super.initState();

    shakeCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 420),
    );

    shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: shakeCtrl, curve: Curves.easeOut));

    // Autofocus setelah dialog tampil
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _doVerify() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      isWrong = false;
    });

    // kecilin delay biar ada "feel" loading saat demo
    await Future.delayed(Duration(milliseconds: 250));

    final pin = widget.controller.text.trim();

    if (pin == widget.expectedPin) {
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    // Salah -> shake + error
    await shakeCtrl.forward(from: 0);

    if (!mounted) return;
    setState(() {
      isWrong = true;
      isLoading = false;
    });

    // pilih semua supaya cepat input ulang
    widget.controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.controller.text.length,
    );
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: EdgeInsets.fromLTRB(18, 18, 18, 0),
      contentPadding: EdgeInsets.fromLTRB(18, 12, 18, 10),
      actionsPadding: EdgeInsets.fromLTRB(14, 0, 14, 14),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lock_rounded, color: Color(0xFF2563EB)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.subtitle,
            style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.35),
          ),
          SizedBox(height: 12),

          AnimatedBuilder(
            animation: shake,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(shake.value, 0),
                child: child,
              );
            },
            child: TextField(
              controller: widget.controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 6,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _doVerify(),
              decoration: InputDecoration(
                labelText: "PIN Presensi (6 digit)",
                counterText: "",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Color(0xFF2563EB), width: 1.6),
                ),
                errorText: isWrong ? "PIN salah. Silakan coba lagi." : null,
                prefixIcon: Icon(Icons.pin_rounded),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context, false),
          child: Text("Batal"),
        ),
        SizedBox(
          height: 42,
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : _doVerify,
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.verified_rounded),
            label: Text(isLoading ? "Memeriksa..." : "Verifikasi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E3A8A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(horizontal: 14),
            ),
          ),
        ),
      ],
    );
  }
}
