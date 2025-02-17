import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Chat Bottom section where the user can type or upload images.
class ChatBottomInputSection extends HookWidget {
  /// Creates a new [ChatBottomInputSection].
  const ChatBottomInputSection({
    required this.chat,
    required this.onMessageSubmit,
    this.onPressSelectImage,
    super.key,
  });

  /// The chat model.
  final ChatModel chat;

  /// Callback function invoked when a message is submitted.
  final Function(String text) onMessageSubmit;

  /// Callback function invoked when the select image button is pressed.
  final VoidCallback? onPressSelectImage;

  @override
  Widget build(BuildContext context) {
    var chatScope = ChatScope.of(context);
    var options = chatScope.options;
    var theme = Theme.of(context);

    var textController = useTextEditingController();
    var isTyping = useState(false);
    var isSending = useState(false);

    useEffect(
      () {
        void listener() => isTyping.value = textController.text.isNotEmpty;
        textController.addListener(listener);
        return () => textController.removeListener(listener);
      },
      [textController],
    );

    Future<void> sendMessage() async {
      isSending.value = true;
      var value = textController.text;
      if (value.isNotEmpty) {
        await onMessageSubmit(value);
        textController.clear();
      }
      isSending.value = false;
    }

    Future<void> Function()? onClickSendMessage;
    if (isTyping.value && !isSending.value) {
      onClickSendMessage = () async => sendMessage();
    }

    /// Image and send buttons
    var messageSendButtons = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onPressSelectImage,
          icon: Icon(
            Icons.image_outlined,
            color: options.iconEnabledColor,
          ),
        ),
        IconButton(
          disabledColor: options.iconDisabledColor,
          color: options.iconEnabledColor,
          onPressed: onClickSendMessage,
          icon: const Icon(Icons.send_rounded),
        ),
      ],
    );

    Future<void> onSubmitField() async => sendMessage();

    var defaultInputField = TextField(
      textAlign: TextAlign.start,
      textAlignVertical: TextAlignVertical.center,
      style: theme.textTheme.bodySmall,
      textCapitalization: TextCapitalization.sentences,
      controller: textController,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.black),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 30,
        ),
        hintText: options.translations.messagePlaceholder,
        hintStyle: theme.textTheme.bodyMedium,
        fillColor: Colors.white,
        filled: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          borderSide: BorderSide.none,
        ),
        suffixIcon: messageSendButtons,
      ),
      onSubmitted: (_) async => onSubmitField(),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: SizedBox(
        height: 45,
        child: options.builders.messageInputBuilder?.call(
              context,
              textController,
              messageSendButtons,
              options.translations,
              onSubmitField,
            ) ??
            defaultInputField,
      ),
    );
  }
}
