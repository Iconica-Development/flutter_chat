import "package:chat_repository_interface/chat_repository_interface.dart";
import "package:flutter/material.dart";
import "package:flutter_accessibility/flutter_accessibility.dart";
import "package:flutter_chat/src/util/scope.dart";
import "package:flutter_hooks/flutter_hooks.dart";

/// Chat Bottom section where the user can type or upload images.
class ChatBottomInputSection extends HookWidget {
  /// Creates a new [ChatBottomInputSection].
  const ChatBottomInputSection({
    required this.chat,
    required this.isLoading,
    required this.onMessageSubmit,
    this.onPressSelectImage,
    super.key,
  });

  /// The chat model.
  final ChatModel? chat;

  /// Whether the chat is still loading.
  /// The inputfield is disabled when the chat is loading.
  final bool isLoading;

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
    var messageSendButtons = SizedBox(
      height: 45,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomSemantics(
            identifier: options.semantics.chatSelectImageIconButton,
            child: IconButton(
              alignment: Alignment.bottomRight,
              onPressed: isLoading ? null : onPressSelectImage,
              icon: Icon(
                Icons.image_outlined,
                color: options.iconEnabledColor,
              ),
            ),
          ),
          CustomSemantics(
            identifier: options.semantics.chatSendMessageIconButton,
            child: IconButton(
              alignment: Alignment.bottomRight,
              disabledColor: options.iconDisabledColor,
              color: options.iconEnabledColor,
              onPressed: isLoading ? null : onClickSendMessage,
              icon: const Icon(Icons.send_rounded),
            ),
          ),
        ],
      ),
    );

    Future<void> onSubmitField() async => sendMessage();

    var defaultInputField = Stack(
      children: [
        CustomSemantics(
          identifier: options.semantics.chatMessageInput,
          isTextField: true,
          child: TextField(
            textAlign: TextAlign.start,
            textAlignVertical: TextAlignVertical.center,
            style: theme.textTheme.bodySmall,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            controller: textController,
            enabled: !isLoading,
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.only(
                left: 16,
                top: 16,
                bottom: 16,
              ),
              // this ensures that that there is space at the end of the
              // textfield
              suffixIcon: ExcludeFocus(
                child: AbsorbPointer(
                  child: Opacity(
                    opacity: 0.0,
                    child: messageSendButtons,
                  ),
                ),
              ),
              hintText: options.translations.messagePlaceholder,
              hintStyle: theme.textTheme.bodyMedium,
              fillColor: Colors.white,
              filled: true,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(25)),
                borderSide: BorderSide.none,
              ),
            ),
            onSubmitted: (_) async => onSubmitField(),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: messageSendButtons,
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: options.spacing.chatSidePadding,
        vertical: 16,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 120, minHeight: 45),
        child: options.builders.messageInputBuilder?.call(
              context,
              textEditingController: textController,
              suffixIcon: messageSendButtons,
              translations: options.translations,
              onSubmit: onSubmitField,
              enabled: !isLoading,
            ) ??
            defaultInputField,
      ),
    );
  }
}
