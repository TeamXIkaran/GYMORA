import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:provider/provider.dart';

enum _Audience { members, trainers }

class OwnerNotificationScreen extends StatefulWidget {
  const OwnerNotificationScreen({super.key});

  @override
  State<OwnerNotificationScreen> createState() =>
      _OwnerNotificationScreenState();
}

class _OwnerNotificationScreenState extends State<OwnerNotificationScreen>
    with SingleTickerProviderStateMixin {
  static const _red = Color(0xFFFF3158);
  static const _redDark = Color(0xFFB91438);

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _selectedRecipients = <String>{};
  final _history = <_SentNotification>[];
  late final AnimationController _shimmerController;

  _Audience _audience = _Audience.members;
  bool _sendToEveryone = true;
  bool _isSending = false;
  String? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OwnerMemberProvider>().ensureLoaded();
      context.read<OwnerTrainerProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  List<_Recipient> _recipients(
    OwnerMemberProvider members,
    OwnerTrainerProvider trainers,
  ) {
    if (_audience == _Audience.members) {
      return members.members
          .map(
            (member) => _Recipient(
              id: member.id,
              name: member.fullName,
              subtitle: '${member.planDisplayName} · ${member.displayStatus}',
            ),
          )
          .toList();
    }

    return trainers.trainers
        .map(
          (trainer) => _Recipient(
            id: trainer.id,
            name: trainer.fullName,
            subtitle: trainer.specialization,
          ),
        )
        .toList();
  }

  List<_MessageTemplate> get _templates => _audience == _Audience.members
      ? const [
          _MessageTemplate(
            name: 'Workout reminder',
            title: 'Time to get moving 💪',
            message:
                'Your workout is waiting for you. Check your plan and make time for a strong session today.',
            icon: Icons.fitness_center_rounded,
          ),
          _MessageTemplate(
            name: 'Consistency check-in',
            title: 'Your next session is calling',
            message:
                'A little progress each day adds up. Book or complete your next workout and keep your momentum going.',
            icon: Icons.local_fire_department_rounded,
          ),
          _MessageTemplate(
            name: 'Membership update',
            title: 'A note about your membership',
            message:
                'Please check your membership status in the app or speak with the gym team if you need help.',
            icon: Icons.card_membership_rounded,
          ),
        ]
      : const [
          _MessageTemplate(
            name: 'Schedule reminder',
            title: 'Please review your training schedule',
            message:
                'Check your upcoming sessions and confirm that your member schedule is up to date.',
            icon: Icons.calendar_month_rounded,
          ),
          _MessageTemplate(
            name: 'Member follow-up',
            title: 'Member follow-up reminder',
            message:
                'Please review your assigned members’ recent activity and follow up with anyone who may need support.',
            icon: Icons.groups_rounded,
          ),
          _MessageTemplate(
            name: 'Workout plan',
            title: 'Workout plans need your attention',
            message:
                'Review assigned workout plans and make sure each member has a suitable next session.',
            icon: Icons.assignment_rounded,
          ),
        ];

  void _changeAudience(_Audience audience) {
    if (_audience == audience) return;
    setState(() {
      _audience = audience;
      _sendToEveryone = true;
      _selectedRecipients.clear();
      _selectedTemplate = null;
      _titleController.clear();
      _messageController.clear();
    });
  }

  void _applyTemplate(_MessageTemplate template) {
    setState(() {
      _selectedTemplate = template.name;
      _titleController.text = template.title;
      _messageController.text = template.message;
    });
  }

  Future<void> _send(List<_Recipient> recipients) async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final sentAudience = _audience;
    final sentAudienceLabel = _audienceLabel;
    final audience = _sendToEveryone
        ? recipients
        : recipients.where((item) => _selectedRecipients.contains(item.id));
    final selected = audience.toList();

    if (title.isEmpty || message.isEmpty) {
      _showSnack('Add a title and message before sending.');
      return;
    }
    if (selected.isEmpty) {
      _showSnack('Choose at least one ${_audienceLabel.toLowerCase()}.');
      return;
    }

    setState(() => _isSending = true);
    // Temporary local response while the notification API is being built.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    setState(() {
      _history.insert(
        0,
        _SentNotification(
          title: title,
          message: message,
          audience: sentAudience,
          recipientCount: selected.length,
          sentAt: DateTime.now(),
        ),
      );
      _isSending = false;
      _titleController.clear();
      _messageController.clear();
      _selectedRecipients.clear();
      _sendToEveryone = true;
      _selectedTemplate = null;
    });
    _showSnack(
      'Demo notification sent to ${selected.length} ${sentAudienceLabel.toLowerCase()}.',
    );
  }

  String get _audienceLabel =>
      _audience == _Audience.members ? 'Members' : 'Trainers';

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF25131A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: _red.withValues(alpha: .2)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07070B),
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-.8, -.9),
                  radius: 1.35,
                  colors: [Color(0x332D1019), Color(0xFF07070B)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Consumer2<OwnerMemberProvider, OwnerTrainerProvider>(
              builder: (context, memberProvider, trainerProvider, _) {
                final recipients = _recipients(memberProvider, trainerProvider);
                final isLoading = _audience == _Audience.members
                    ? memberProvider.isLoading && !memberProvider.hasLoaded
                    : trainerProvider.isLoading && !trainerProvider.hasLoaded;
                final error = _audience == _Audience.members
                    ? memberProvider.error
                    : trainerProvider.error;

                return Column(
                  children: [
                    _header(),
                    Expanded(
                      child: isLoading
                          ? _loadingView()
                          : error != null && recipients.isEmpty
                          ? _errorView(error)
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildAudiencePicker(
                                    memberProvider.members.length,
                                    trainerProvider.trainers.length,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildComposer(recipients),
                                  const SizedBox(height: 22),
                                  _buildHistory(),
                                ],
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          _IconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.pop(),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TEAM COMMUNICATION',
                  style: TextStyle(
                    color: _red,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Send the right update to your team',
                  style: TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          const _DemoBadge(),
        ],
      ),
    );
  }

  Widget _buildAudiencePicker(int memberCount, int trainerCount) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeading(
            title: 'Choose audience',
            subtitle: 'Notifications go only to members or trainers.',
            icon: Icons.groups_rounded,
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _AudienceCard(
                  title: 'Members',
                  subtitle: 'Workout & membership updates',
                  count: memberCount,
                  icon: Icons.person_rounded,
                  selected: _audience == _Audience.members,
                  onTap: () => _changeAudience(_Audience.members),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AudienceCard(
                  title: 'Trainers',
                  subtitle: 'Schedule & client updates',
                  count: trainerCount,
                  icon: Icons.fitness_center_rounded,
                  selected: _audience == _Audience.trainers,
                  onTap: () => _changeAudience(_Audience.trainers),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(List<_Recipient> recipients) {
    final selectedCount = _sendToEveryone
        ? recipients.length
        : recipients
              .where((item) => _selectedRecipients.contains(item.id))
              .length;

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeading(
            title: 'Compose update',
            subtitle: 'Create a useful message for $_audienceLabel.',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: 16),
          const Text(
            'QUICK TEMPLATES',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 9),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final template in _templates)
                _TemplateChip(
                  template: template,
                  selected: _selectedTemplate == template.name,
                  onTap: () => _applyTemplate(template),
                ),
            ],
          ),
          const SizedBox(height: 18),
          _textField(
            controller: _titleController,
            label: 'Notification title',
            hint: 'Write a short, clear title',
            icon: Icons.title_rounded,
            maxLength: 60,
          ),
          const SizedBox(height: 12),
          _textField(
            controller: _messageController,
            label: 'Message',
            hint: 'Share the update or next step...',
            icon: Icons.notes_rounded,
            maxLength: 240,
            maxLines: 4,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'SEND TO',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Text(
                '$selectedCount ${_audienceLabel.toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Expanded(
                child: _ScopeButton(
                  label: 'Everyone',
                  selected: _sendToEveryone,
                  onTap: () => setState(() => _sendToEveryone = true),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _ScopeButton(
                  label: 'Choose people',
                  selected: !_sendToEveryone,
                  onTap: () => setState(() => _sendToEveryone = false),
                ),
              ),
            ],
          ),
          if (!_sendToEveryone) ...[
            const SizedBox(height: 10),
            _recipientSelector(recipients),
          ],
          const SizedBox(height: 18),
          ShimmerButton(
            shimmerCtrl: _shimmerController,
            gradientColors: const [_red, _redDark],
            accentColor: _red,
            height: 54,
            enabled: !_isSending && selectedCount > 0,
            onPressed: () => _send(recipients),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSending)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 9),
                Text(
                  _isSending ? 'Preparing demo send...' : 'Send notification',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Demo only · Nothing is delivered outside this screen yet.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _recipientSelector(List<_Recipient> recipients) {
    if (recipients.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'No recipients are available for this audience yet.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 11),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 230),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: recipients.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          indent: 52,
          color: Colors.white.withValues(alpha: .05),
        ),
        itemBuilder: (context, index) {
          final recipient = recipients[index];
          final selected = _selectedRecipients.contains(recipient.id);
          return CheckboxListTile(
            value: selected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedRecipients.add(recipient.id);
                } else {
                  _selectedRecipients.remove(recipient.id);
                }
              });
            },
            activeColor: _red,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.trailing,
            dense: true,
            secondary: CircleAvatar(
              radius: 17,
              backgroundColor: _red.withValues(alpha: .14),
              child: Text(
                _initials(recipient.name),
                style: const TextStyle(
                  color: Color(0xFFFF8194),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            title: Text(
              recipient.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              recipient.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          );
        },
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required int maxLength,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : 3,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          cursorColor: _red,
          decoration: InputDecoration(
            counterStyle: const TextStyle(color: Colors.white30, fontSize: 8),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: const Color(0xFFFF7187), size: 18)
                : null,
            prefix: maxLines == 1
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(icon, color: const Color(0xFFFF7187), size: 18),
                  ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: .025),
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: _red.withValues(alpha: .65)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: _SectionHeading(
                title: 'Recent sends',
                subtitle: 'Local demo activity',
                icon: Icons.schedule_rounded,
              ),
            ),
            if (_history.isNotEmpty)
              Text(
                '${_history.length}',
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          _Panel(
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: Color(0xFFFF7187),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your demo sends will appear here after you send an update.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          for (final item in _history) ...[
            _HistoryCard(notification: item),
            const SizedBox(height: 9),
          ],
      ],
    );
  }

  Widget _loadingView() =>
      const Center(child: CircularProgressIndicator(color: _red));

  Widget _errorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, color: _red, size: 42),
            const SizedBox(height: 12),
            Text(
              'Could not load $_audienceLabel',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {
                if (_audience == _Audience.members) {
                  context.read<OwnerMemberProvider>().fetchMembers();
                } else {
                  context.read<OwnerTrainerProvider>().fetchTrainers();
                }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: TextButton.styleFrom(foregroundColor: _red),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    return parts.length == 1
        ? parts.first.substring(0, 1).toUpperCase()
        : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class _Recipient {
  const _Recipient({
    required this.id,
    required this.name,
    required this.subtitle,
  });

  final String id;
  final String name;
  final String subtitle;
}

class _MessageTemplate {
  const _MessageTemplate({
    required this.name,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String name;
  final String title;
  final String message;
  final IconData icon;
}

class _SentNotification {
  const _SentNotification({
    required this.title,
    required this.message,
    required this.audience,
    required this.recipientCount,
    required this.sentAt,
  });

  final String title;
  final String message;
  final _Audience audience;
  final int recipientCount;
  final DateTime sentAt;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B1118), Color(0xFF100D13)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x44FF3158)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3158).withValues(alpha: .045),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFF3158).withValues(alpha: .11),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFFF7187), size: 19),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AudienceCard extends StatelessWidget {
  const _AudienceCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF3158).withValues(alpha: .10)
                : Colors.white.withValues(alpha: .025),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected
                  ? const Color(0x99FF3158)
                  : Colors.white.withValues(alpha: .07),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3158).withValues(alpha: .13),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFFF7187), size: 19),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '$count',
                          style: const TextStyle(
                            color: Color(0xFFFF8194),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final _MessageTemplate template;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(
        template.icon,
        size: 14,
        color: selected ? Colors.white : const Color(0xFFFF7187),
      ),
      label: Text(template.name),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
      side: BorderSide(
        color: selected
            ? const Color(0xFFFF3158)
            : Colors.white.withValues(alpha: .08),
      ),
      backgroundColor: selected
          ? const Color(0xFFFF3158).withValues(alpha: .20)
          : Colors.white.withValues(alpha: .035),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ScopeButton extends StatelessWidget {
  const _ScopeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected
            ? const Color(0xFFFF3158).withValues(alpha: .13)
            : Colors.white.withValues(alpha: .02),
        foregroundColor: selected ? const Color(0xFFFF8194) : Colors.white60,
        side: BorderSide(
          color: selected
              ? const Color(0xAAFF3158)
              : Colors.white.withValues(alpha: .08),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
      ),
      child: Text(label),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.notification});

  final _SentNotification notification;

  @override
  Widget build(BuildContext context) {
    final label = notification.audience == _Audience.members
        ? 'Members'
        : 'Trainers';
    final time = notification.sentAt;
    final timeLabel =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .035),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: .07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFF3158).withValues(alpha: .11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Color(0xFFFF7187),
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    _HistoryTag(label: label),
                    _HistoryTag(
                      label: '${notification.recipientCount} recipients',
                    ),
                    _HistoryTag(label: timeLabel),
                    const _DemoBadge(compact: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTag extends StatelessWidget {
  const _HistoryTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFF3158).withValues(alpha: .10),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0x55FF3158)),
      ),
      child: Text(
        'DEMO',
        style: TextStyle(
          color: const Color(0xFFFF8194),
          fontSize: compact ? 7 : 8,
          fontWeight: FontWeight.w900,
          letterSpacing: .8,
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .045),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white70, size: 19),
        ),
      ),
    );
  }
}
